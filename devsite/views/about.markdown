## About CitySDK Linked Open Data Distribution API

<table id="about">
  <tr>
    <td>
      <p>The concept of CitySDK Linked Data API is best explained using Tim Berners-Lee’s <a href="http://5stardata.info/">Five Star Linked Open Data model</a>.</p>
      <p>
On the right, you see a city. Like more and more cities all over Europe, this city is opening its data to the public, and making it available through data catalog portals like <a href="http://ckan.org/">CKAN</a>. Moreover, it is also working on APIs and services to facilitate the communication with citizens (i.e. <a href="http://open311.org/">Open311</a>).
      </p>
    </td>
    <td class="number"><div>1</div></td>
    <td><img src="img/city-01.png" /></td>
  </tr>
  <tr>
    <td>
Although many different open datasets are available through this city’s data catalog, it’s not always easy for developers to use the data. Data is offered in different file formats, has unclear update policies and incomplete metadata. When the data is accessible under an open license and offered in a structured and non-propriatory format, the data is rated with three stars.
  </td>
  <td class="number"><div>2</div></td>
  <td><img src="img/city-02.png" /></td>
</tr>
<tr>
  <td>
Moreover, it can be difficult to find out that different datasets have data about the same objects. According to the five star model, URIs should be used to uniquely identify objects and links should be created between those objects to define relations; it is not unusual that data about one object is contained in multiple datasets.
  </td>
  <td class="number"><div>3</div></td>
  <td><img src="img/city-03.png" /></td>
</tr>
<tr>
  <td>
    The city on the right has decided to use CitySDK to give all individual objects - such as buildings, public parks and bus stops (or train stations, bridges, museums and parking garages) - a unique identifier. This URI can then be used to identify those objects across multiple datasets.
  </td>
  <td class="number"><div>4</div></td>
  <td><img src="img/city-04.png" /></td>
<tr>
  <td>
All objects with an URI have a geographic location, and are called a node within CitySDK. To those nodes, per layer, key-value data can be added. For example:  the URI of a bus stop can be used to access bus schedules, but also in Open311 service requests, and with the URI of a road, data about planned roadworks and traffic information can be accessed.
  </td>
  <td class="number"><div>5</div></td>  
  <td><img src="img/city-05.png" /></td>
</tr>
<tr>
  <td>
Many of the datasets in open data catalog contain data about objects that exist in the real world. This is why CitySDK uses the <a href="http://www.openstreetmap.org/">OpenStreetMap</a> database as a geospatial base layer. Via CitySDK, all nodes, ways and relations from OSM can be used to attach data from other open datasets to. GTFS data will be attached to OSM bus stops and train stations, tourist information will be attached to OSM museums and theatres and planned roadwork data to OSM roads.
  </td>
  <td class="number"><div>6</div></td>  
  <td><img src="img/city-06.png" /></td>
</tr>
<tr>
  <td>
CitySDK is a linked open data distribution platform - for static and real-time data - and connects existing open datasets, data catalogs and APIs. CitySDK provides one easy to use REST API with both JSON and <a href="http://www.w3.org/TeamSubmission/turtle/">Turtle/RDF</a> output. With this API, datasets that were previously difficult to access and use can be accessed in a single unified way, on an per-object basis.

Datasets in the following categories are currently accessible for multiple European cities using CitySDK Linked Data API:

<ul>
<li>Public transport data (GTFS) 	&ndash; static &amp; real-time</li>
<li>Traffic, parking and electric vehicle charging points</li>
<li>OpenStreetMap</li>
<li>Buildings and addresses</li>
<li>Census and statistics data</li>
<li>POIs and events</li>
</ul>
  </td>
  <td class="number"><div>7</div></td>  
  <td><img src="img/city-07.png" /></td>
</tr>
</table>