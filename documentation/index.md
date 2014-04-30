---
layout: default
title: Documentation
mainmenu: GettingStarted
published: true
---

#Documentation

## Getting Started

The best tool to get a grip on the available open data is the List of datasets<link> combined with the Map Viewer<link>.

- Each datasets in the List of Datasets has a link tot he map viewer which gives you an instant view of datapoints in JSON with a corresponding Map View
- The query field on the Map Viewer also has a drop down menu with a number of example queries. 
 
## Developer Documentation API
This unified REST API gives access to unified data from different sources available on a per-object basis. The JSON and RDF API is written in Ruby + Sinatra. Data is stored in PostgreSQL/PostGIS database. Documentation and source code can all be found on GitHub and there’s also a Ruby API gem.

**This website contains endpoint specific information only**, mainly regarding the datasets available here. Alle general documentation on the API can be found on the wiki at the corresponding [GitHub repository](https://github.com/waagsociety/citysdk-ld).
 
To get started there’s a Swagger implementation available here: <link>.
 
## Discovery API
To know which CitySDK API’s are available for which geography/jurisdiction there’s a project wide Discovery API at [http://cat.citysdk.eu/](http://cat.citysdk.eu/)