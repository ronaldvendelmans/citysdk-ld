
## API examples

<ul>
{% for example in site.data.endpoint.examples %}
  <li>
    <a href="{{ site.baseurl }}/map#{{ example.url }}">{{ example.title }}</a>
  </li>
{% endfor %}
</ul>