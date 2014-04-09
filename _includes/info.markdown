
## Links

<ul>
  <li><a href="http://www.citysdk.eu/">CitySDK project site</a></li>
  <li><a href="{{ site.data.endpoint.endpoint }}">CitySDK Linked Data API endpoint</a></li>
  <li><a href="http://www.citysdk.eu/developers/">Additional APIs in the CitySDK toolkit</a></li>
  <li><a href="{{ site.data.endpoint.github }}">GitHub repository</a></li>
  {% for link in site.data.endpoint.links %}
  <li>
    <a href="{{ link.url }}">
      {{ link.title }}
    </a>
  </li>
  {% endfor %}
</ul>

Data sources currently available:

<ul>
{% for dataset in site.data.endpoint.datasets %}
  <li>
    <a href="{{ dataset.url }}">{{ dataset.title }}</a>
  </li>
{% endfor %}
</ul>

## API examples

<ul>
{% for example in site.data.endpoint.examples %}
  <li>
    <a href="{{ site.baseurl }}/map#{{ example.url }}">{{ example.title }}</a>
  </li>
{% endfor %}
</ul>