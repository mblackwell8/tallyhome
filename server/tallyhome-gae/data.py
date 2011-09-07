import cgi
import datetime
import urllib
import wsgiref.handlers

from google.appengine.ext import db
from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app

class Tally(db.Model):
  TallyClassName = db.StringProperty()		# eg. houseprice
  RegionSeriesName = db.StringProperty()
  RegionType = db.StringProperty()
  RegionNameSource = db.StringProperty()
  SourceType = db.StringProperty()
  IxName = db.StringProperty()
  SupplementaryData = db.StringProperty()	# eg. avg house value

class TallyDataPoint(db.Model):
  Tally_ID = db.ReferenceProperty(Tally)
  Date = db.DateProperty()
  IxVal = db.FloatProperty()
  SupplementaryData = db.StringProperty()

#could use a PolyModel for these DataMappings

class CityDataMapping(db.Model):
  CityName = db.StringProperty()
  Location = db.GeoPtProperty()
  RegionSeriesName = db.StringProperty()
  RegionNameSource = db.StringProperty()
  StateName = db.StringProperty()
  State_ID = db.ReferenceProperty(StateDataMapping)

class StateDataMapping(db.Model):
  StateName = db.StringProperty()
  Location = db.GeoPtProperty()
  RegionSeriesName = db.StringProperty()
  RegionNameSource = db.StringProperty()
  CountryName = db.StringProperty()
  Country_ID = db.ReferenceProperty(CityDataMapping)

class CountryDataMapping(db.Model):
  CountryName = db.StringProperty()
  Location = db.GeoPtProperty()
  RegionSeriesName = db.StringProperty()
  RegionNameSource = db.StringProperty()


def tally_key(tally_name=None):
  return db.Key.from_path('Tally', tally_name or 'default_tally')

class GetTally(webapp.RequestHandler):
  def get(self):
    self.response.out.write('data')
    # walk city, state then country mapping to get best index identifier
    # each search may generate multiple matches, so test each match against state and country

    # filter main database for this index and for the requested TallyClassName

    # return as XML

application = webapp.WSGIApplication([
#  ('/', MainPage),
  ('/data', GetTally)
], debug=True)


def main():
  run_wsgi_app(application)


if __name__ == '__main__':
  main()
