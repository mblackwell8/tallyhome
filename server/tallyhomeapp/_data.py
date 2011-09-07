import cgi
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

#could use a PolyModel for these DataMappings

class PlaceMap(db.Model):
    Name = db.StringProperty()
    Location = db.GeoPtProperty()
    RegionSeriesName = db.StringProperty()
    RegionNameSource = db.StringProperty()
    ParentPlaceName = db.StringProperty()

class UserInteraction(db.Model):
    Device = db.StringProperty() # can't be UDID anymore, so just create a GUID and use that
    When = db.DateTimeProperty()
    ReqURL = db.StringProperty()
    Response = db.StringProperty() #http response code... 200 etc


class GetTally(webapp.RequestHandler):
    def get(self):
        try:
            
            #first log the user interaction
            #ui = UserInteraction()
            #ui.User = self.request...
            #ui.When = 
            #ui.ReqURL =    
    
            self.response.out.write('<?xml version="1.0" encoding="UTF-8"?>')
            self.response.out.write('<TallyHomeDataFile version="1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">')
        
            # current implementation v. simple

            #look up city in PlaceMap table names
            city = self.request.get('city')
            cityPMs = PlaceMap.all().filter('Name =', city)

            #select from returned records vs provided lat/long, state and country
            #if in doubt, return all and let the client side remove excess

            #ignore for v1, Oz only
            #if len(cityPMs.get()) == 0: 
            #    self.response.out.write('Error!')
            #    #ui.Response = 'Error'
            #    #ui.put()
            #    return

            #collect PlaceMap(s) from city (may be multiple)
            placeMaps = []
            placeMaps.extend(cityPMs)

            #look up state for first city (assume that step above aligned them all to be same)
            statePMs = PlaceMap.all().filter('Name =', cityPMs[0].ParentPlaceName)

            #collect PlaceMap(s) from state (may be multiple)
            placeMaps.extend(statePMs)

            #look up country for first state
            ctryPMs = PlaceMap.all().filter('Name =', statePMs[0].ParentPlaceName)

            #collect PlaceMap(s) from country (may be multiple)
            placeMaps.extend(ctryPMs)


            #need to calc av house price... data should be in cities only
            avHousePrices = []

            #for each PlaceMap, look up Tally
            self.response.out.write('<Indexes')
            for placeMap in placeMaps:
                tallies = Tally.all().filter('RegionSeriesName =', placeMap.RegionSeriesName).filter('RegionNameSource =', placeMap.RegionNameSoure).filter('TallyClassName =', self.request.get('tallyID'))
                #tallies = Tally.all().filter('RegionSeriesName =', 'A2333534T').filter('RegionNameSource =', 'ABS').filter('TallyClassName =', self.request.get('tallyID'))
				
                #avHousePrices.append( **** parse out of Supp data *****)

                #should be only one, so
                tally = tallies[0]

                #for each Tally, build XML header and indices
                # <Index name="ABS House Price Index (Sydney, Established homes)" prox="City" sourceType="Government">
                self.response.out.write('<Index name="%s" prox="%s" sourceType="%s"' % (tally.IxName, tally.RegionType, tally.SourceType))
                for dp in TallyDataPoint.all().ancestor(tally):
                    # <Indice date="2002-03-01T00:00:00Z" value="75.9" />
                    self.response.out.write('<Indice date="%s" value="%s" />' % (dp.Date, dp.IxVal))

                self.response.out.write('</Index>')

            #self.response.out.write( *** av house price
            self.response.out.write('</Indexes>')
            

            self.response.out.write('</TallyHomeDataFile>')
            #ui.Response = 'Success'
            #ui.put()


                
                
        except DeadlineExceededError:
            self.response.clear()
            self.response.set_status(500)
            self.response.out.write("This operation could not be completed in time...")


application = webapp.WSGIApplication([
    #  ('/', MainPage),
    ('/data', GetTally)
    ], debug=True)

#probably want an update only URL to minimize resource use

def main():
    run_wsgi_app(application)

if __name__ == '__main__':
    main()
