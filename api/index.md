---
layout: api
title: API
---

## API guide

(QED apr 14) CitySDK Linked Data API links datasets through addressable, real-world objects. The organization of the information is extremely simple; there are nodes and information on these nodes. A node can be anything; a landmark, a bus-stop, a stretch of road, a town or a public transport line. All nodes are a `node`, but there are multiple types of nodes which are treated specially: these are `route`, `region`, `ptstop` and `ptline`. A route is a series of nodes in a particular order. A region is a node that represents a formal administrative region. Since the API also deals with open government data, it is convenient to have these nodes available as a shortcut. This allows for easy attachment of data on towns, suburbs and neighborhoods. We define the country as level 0, the provinces as 1, the municipalities as level 3 (level 2 is for larger regions that are not provinces, like Stadsregio Amsterdam), quarters ('wijken') are level 4, neigborhoods are level 5. Amsterdam also defines an even smaller area, level 6. We are assessing whether to bring these levels in line with the levels as used in OSM, so this may change. `ptstop` and `ptline` nodes represent public transport stops and lines.

There is a further entity, the `layer`. Layers are the means through which the data is organized, and through which data is addressed and updated. A layer has an `owner` who will be responsible for the data on that layer. A layer is also the organizational unit through which applications will write to the API. The app reads and processes information from any layer, but writes only to its own layer(s). The base geography data lives in the OpenStreetMap layer (name: `osm`); this basically represents the OSM nodes, ways and relations. The regions live in the `admr` layer, public transport is on the `gtfs` layer. Nodes are uniquely addressable through their `cdk_id`. Although the `cdk_id` of a node is not meant to represent data or information, conventions that we implement, and are handy to remember when exploring the API. For example: `gtfs.line.gvb.25-1` represents southbound GVB tram line 25, `admr.nl.amsterdam` represents the municipality of Amsterdam and `admr.nl.amsterdam_stadsdeel_centrum` represents the city center of Amsterdam.