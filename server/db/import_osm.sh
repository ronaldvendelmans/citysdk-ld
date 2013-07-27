# Import OSM file into citysdk database
# OSM file used here: netherlands-latest.osm.bz2
osm2pgsql --slim -j -d citysdk -l -C6000 -U postgres <file>

# Move OSM data to schema osm
psql -d citysdk -U postgres < osm_schema.sql


# # for each additional country or regionp:
#  
# osm2pgsql --slim -d citysdk -l -C2000 -U postgres <additional>.osm.bz2
# 
# # Merge OSM data
# psql -d citysdk -U postgres < osm_merge.sql
