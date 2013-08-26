OSM data must be in database `citysdk` and schema `osm`

    CREATE SCHEMA osm;

    ALTER TABLE planet_osm_line SET SCHEMA osm;
    ALTER TABLE planet_osm_nodes SET SCHEMA osm;
    ALTER TABLE planet_osm_point SET SCHEMA osm;
    ALTER TABLE planet_osm_polygon SET SCHEMA osm;
    ALTER TABLE planet_osm_rels SET SCHEMA osm;
    ALTER TABLE planet_osm_roads SET SCHEMA osm;
    ALTER TABLE planet_osm_ways SET SCHEMA osm;


Tilemill requires node.js 0.8.17

`sudo npm install -g n`

`sudo n 0.8.17`

n use 0.8.17
