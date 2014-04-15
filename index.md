---
layout: default
title: Home
---

<div class="col_12" >
	
## CitySDK Linked Data API

(QED) The CitySDK Linked Open Data Distribution API is a linked data distribution platform. Developed by Waag Society, the distribution API is a component of the [CitySDK toolkit](http://citysdk.eu). This toolkit supports the development of open and interoperable interfaces for open data and city services in eight European cities (Amsterdam, Helsinki, Manchester, Lisbon, Istanbul, Lamia, Rome and Barcelona). The CitySDK Linked Open Data Distribution API enables the distribution and linking of open data sets and city services. This website explains the distribution API. For a comprehensive overview of the complete CitySDK toolkit have a look at the [CitySDK project homepage](http://www.citysdk.eu/).

</div>
<hr/>	
<div class="col_7" >

### Benefits

1. CitySDK Linked Open Data Distribution API is a one-stop-shop for developers. With standardized interfaces, developers can build better apps and services for end users and governments. 
2. _Moveable code_ &ndash; developers can use the same interface for open data, in Amsterdam, Helsinki and Istanbul alike.
3. The API enables the _Read/Write City_: per layer, data can be added to objects the city, using URIs.
4. Data exchange between citizens and the city will become open, more efficient and more transparent data.
5. The API enables innovation for businesses, media and citizens, and Manages the constant technological change: adding new datasets and services is made easy.
6. The API is released as [open source on GitHub]({{ site.data.endpoint.github }}), and can easily be implemented and amended to local needs.

### Features

* Open API, open source
* Unified REST API, data from different sources available on a per-object basis
* No access keys for reading
* Write access for data owners and app developers
* CMS for data owners for easy integration of new datasets
* Interactive linking of data sets
* [Map viewer]({{ site.baseurl }}/map)
* Standardized interface in 8 cities
* [Ruby API gem](http://rubygems.org/gems/citysdk)

### Technical details

* JSON and RDF API written in Ruby + [Sinatra](http://www.sinatrarb.com/)
* Data stored in PostgreSQL/PostGIS database

### Adding your own data
If you are a data owner, the API offers a user-friendly <a href="{{ site.data.endpoint.cms }}">CMS</a>.
It makes it easy to upload and (automatically) update your static and realtime data sets. To get a login, send an email to <a href="mailto:{{ site.data.endpoint.email }}">CitySDK support</a>.

### Interested?
If your city is interested in CitySDK and the API interface and toolkit, or if you are a developer looking to develop apps that work in different European cities, then get in touch via <a href="mailto:{{ site.data.endpoint.email }}">CitySDK support</a>.

</div>
<div class=" col_1"></div>
<div class=" col_4  gridsmaller">

### Links

* <a href="http://www.citysdk.eu/">CitySDK project site</a></li>
* <a href="http://api.citysdk.waag.org/">CitySDK Linked Data API endpoint</a></li>
* <a href="http://dev.citysdk.waag.org/visualisation/">Visualization of real-time CitySDK LD API mobility data</a></li>
* <a href="http://dev.citysdk.waag.org/buildings/">Map with building and address data</a></li>
* <a href="http://www.citysdk.eu/developers/">Additional APIs in the CitySDK toolkit</a> </li>

		
### API examples

* <a href="http://api.citysdk.waag.org/admr.nl.zwolle/regions?admr::admn_level=4&amp;layer=cbs&amp;per_page=50">Statistical data of all neighbourhoods in Zwolle</a></li>
* <a href="http://api.citysdk.waag.org/admr.nl.groningen/regions?admr::admn_level=4&amp;layer=rain">Rain forecast per neighbourhood in Groningen</a></li>
* <a href="http://api.citysdk.waag.org/admr.nl.nederland/nodes?admr::admn_level=3&amp;per_page=500">All municipalities in the Netherlands</a></li>
* <a href="http://api.citysdk.waag.org/admr.nl.utrecht/nodes?osm::tourism=museum&amp;per_page=50">Museums in Utrecht</a></li>
* <a href="http://api.citysdk.waag.org/admr.nl.utrecht/cbs/aant_inw">Number of inhabitants of Utrecht</a></li>
* <a href="http://api.citysdk.waag.org/admr.nl.amsterdam/ptstops?name=Leidseplein">Public transport stops in Amsterdam named Leidseplein</a></li>
* <a href="http://api.citysdk.waag.org/gtfs.stop.060671/select/ptlines">Tram lines that call at a specific stop</a></li>
* <a href="http://api.citysdk.waag.org/gtfs.stop.060671/select/now">Next hour&#39;s schedule for this stop</a></li>
* <a href="http://api.citysdk.waag.org/n798432345/select/regions">Adminstrative regions which contain the Olympic Stadium in Amsterdam</a></li>


### Participants
		
	<div class="logos">
		<p><a href="http://www.waag.org/"><img src="http://dev.citysdk.waag.org//img/waag-small.png" /></a></p>
		<p><a href="http://www.citysdk.eu/"><img src="http://dev.citysdk.waag.org//img/citysdk-small.png" /></a></p>
		<p><a href="http://ec.europa.eu/information_society/activities/ict_psp/about/index_en.htm"><img src="http://dev.citysdk.waag.org//img/ict-psp.png" /></a></p>
		<p><a href="http://europa.eu/"><img src="http://dev.citysdk.waag.org//img/europa.png" /></a></p>
		<p><a href="http://creativecommons.nl/wie-zijn-we/"><img src="http://dev.citysdk.waag.org//img/cc.png" /></a></p>
	</div>
		
</div>
