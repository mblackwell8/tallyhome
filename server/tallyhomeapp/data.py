import cgi
import logging
import datetime
import urllib
import wsgiref.handlers

from google.appengine.ext import db
#from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.runtime import DeadlineExceededError


class Tally(db.Model):
    TallyClassName = db.StringProperty()        # eg. houseprice
    RegionSeriesName = db.StringProperty()
    RegionType = db.StringProperty()
    RegionNameSource = db.StringProperty()
    SourceType = db.StringProperty()
    IxName = db.StringProperty()
    SupplementaryData = db.StringProperty() # eg. avg house value

class TallyDataPoint(db.Model):
    Tally_ID = db.ReferenceProperty(Tally)
    Date = db.DateProperty()
    IxVal = db.FloatProperty()
    SupplementaryData = db.StringProperty()

class PlaceMap(db.Model):
    Name = db.StringProperty()
    Class = db.StringProperty()
    Location = db.GeoPtProperty()
    RegionSeriesName = db.StringProperty()
    RegionNameSource = db.StringProperty()
    ParentPlaceName = db.StringProperty()

class UserInteraction(db.Model):
    Device = db.StringProperty() # can't be UDID anymore, so just create a GUID and use that
    When = db.DateTimeProperty(auto_now=True)
    ReqURL = db.StringProperty()
    ReqIP = db.StringProperty()
    Response = db.StringProperty() #use http response code... 200 etc

class ResultCache(db.Model):
    City = db.StringProperty()
    State = db.StringProperty()
    Country = db.StringProperty()
    TallyClassName = db.StringProperty()
    DateCached = db.DateTimeProperty(auto_now=True)
    Response = db.TextProperty() #doco says cannot be empty string

class ResultLog(db.Model):
    When = db.DateTimeProperty(auto_now=True)
    ReqURL = db.StringProperty()
    Response = db.TextProperty()

class GetTally(webapp.RequestHandler):
    def get_response(self,city,state,country,tallyID):
        
        self.response.out.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        self.response.out.write('<TallyHomeDataFile version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">\n')

        placeMaps = []

        #look up city in PlaceMap table names
        cityPMs = PlaceMap.all().filter('Class =', 'City').filter('Name =',
                city).filter('ParentPlaceName =', state)
        for cityPM in cityPMs:
            if cityPM.RegionSeriesName is not None and cityPM.RegionNameSource is not None:
                placeMaps.append(cityPM)

        statePMs = PlaceMap.all().filter('Class =', 'State').filter('Name =',
                state).filter('ParentPlaceName =', country) 
        for statePM in statePMs:
            if statePM.RegionSeriesName is not None and statePM.RegionNameSource is not None:
                placeMaps.append(statePM)

        ctryPMs = PlaceMap.all().filter('Class =', 'Country').filter('Name =',
                country)
        for ctryPM in ctryPMs:
            if ctryPM.RegionSeriesName is not None and ctryPM.RegionNameSource is not None:
                placeMaps.append(ctryPM) 
        
        #for each PlaceMap, look up Tally
        talliesDone = []
        self.response.out.write('<Indexes>')
        for placeMap in placeMaps:
            tallies = Tally.all().filter('RegionSeriesName =', placeMap.RegionSeriesName) \
                    .filter('RegionNameSource =', placeMap.RegionNameSource) \
                    .filter('TallyClassName =', tallyID)

            if tallies.count(1) == 0:
                continue;

            #should be only one, so
            tally = tallies[0]

            if tally.key() in talliesDone:
                continue

            talliesDone.append(tally.key())

            # <Index name="ABS House Price Index (Sydney, Established homes)" prox="City" sourceType="Government">
            self.response.out.write('<Index name="%s" prox="%s" sourceType="%s">\n' % (tally.IxName, tally.RegionType, tally.SourceType))
            #HACK: crappy implementation
            if tally.SupplementaryData is not None:
                suppItems = tally.SupplementaryData.split(',')
                avPriceStr = suppItems[0].split('=')[1]
                avPriceDtStr = suppItems[1].split('=')[1]
                self.response.out.write("""<AverageHousePrice>\n<Indice date=%s
                        value=%s />\n</AverageHousePrice>\n""" % (avPriceDtStr, avPriceStr))
                #for each Tally, build XML header and indices
            # ancestor doesn't work...
            # ... and can't get order() working either
            for dp in TallyDataPoint.all() \
                    .filter('Tally_ID =', tally.key()):
                # <Indice date="2002-03-01T00:00:00Z" value="75.9" />
                self.response.out.write('<Indice date="%s" value="%s" />\n' % (dp.Date.strftime("%Y-%m-%d"), dp.IxVal))

            self.response.out.write('</Index>\n')

        self.response.out.write('</Indexes>\n')
        self.response.out.write('</TallyHomeDataFile>')

    def get(self):
        try:

            #first log the user interaction
            ui = UserInteraction()
            ui.Device = self.request.get('userID')
            ui.ReqURL = self.request.url
            ui.ReqIP = self.request.remote_addr
            ui.Response = 'No response yet'
            try:
                ui.put()
            except CapabilityDisabledError:
                # doesn't really matter
                pass


            city = self.request.get('city')
            state = self.request.get('state')
            country = self.request.get('country')
            tallyID = self.request.get('tallyID')

            cachedResults = ResultCache.all().filter('City =', city) \
                                            .filter('State =', state) \
                                            .filter('Country =', country) \
                                            .filter('tallyID =', tallyID)

            # if we have a cached result and it is less than a month old, let's
            # use it and return immediately
            if cachedResults.count(2) > 1:
                logging.error('more than one cached result for URL: %s' %
                        (self.request.url))

            cachedRes = None
            if cachedResults.count(1) > 0:
                cachedRes = cachedResults[0]
            if cachedRes is not None and datetime.now() - cachedRes.DateCached < (60 * 24 * 30):
                self.response.out.write(cachedRes.Response)
                logging.debug('found cached result for URL: %s' %
                        (self.request.url))
            else:
                if cachedRes is not None:
                    logging.debug('removing old cached result for URL: %s' %
                            (self.request.url))
                for res in cachedResults:
                    res.delete()

                self.get_response(city,state,country,tallyID)

                cr = ResultCache()
                cr.City = city
                cr.State = state
                cr.Country = country
                cr.TallyClassName = tallyID
                cr.Response = self.response.out.getvalue()
                try:
                    cr.put()
                except CapabilityDisabledError:
                    # doesn't really matter
                    pass


            ui.Response = '200'
            try:
                ui.put()
            except CapabilityDisabledError:
                # doesn't really matter
                pass

        except DeadlineExceededError:
            self.response.clear()
            self.response.set_status(500)
            self.response.out.write("This operation could not be completed in time...")


class TallyDataPointLoader(webapp.RequestHandler):
    def get(self):
        pass

class AveragePriceLoader(webapp.RequestHandler):
    def get(self):
        seriesName = self.request.get('RegionSeriesName')
        seriesSrc = self.request.get('RegionNameSource')
        avgPrice = self.request.get('avgPrice')
        avgPriceDt = self.request.get('avgPriceDt')

        tallies = Tally.all().filter('RegionSeriesName =', seriesName)\
                             .filter('RegionNameSource =', seriesSrc)
        num = tallies.count(2)
        if num == 0 or num > 1:
            self.response.set_status(400)
            self.response.out.write('Error. No series/src found')
            return

        tally = tallies[0]
        tally.SupplementaryData = 'AvPrice="%s",AvPriceDt="%s"' % (avgPrice,
                avgPriceDt)
        tally.put()
        self.response.set_status(200)
        self.response.out.write('OK')


application = webapp.WSGIApplication([
    #  ('/', MainPage),
    ('/v1/data', GetTally),
    ('/loader', TallyDataPointLoader),
    ('/avgPrice', AveragePriceLoader)
    ], debug=True)

#probably want an update only URL to minimize resource use

def main():
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
