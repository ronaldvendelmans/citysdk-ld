---
layout: default
title: Start
---

#Documentation

## Input

The Match API expects JSON in the following form:

<pre>{
  &quot;match&quot;: {
    &quot;params&quot;: {
      &quot;radius&quot;: 350,
      &quot;debug&quot;: true,
      &quot;srid&quot;: 4326,
      &quot;geometry_type&quot;: &quot;point&quot;,
      &quot;layers&quot;: {
        &quot;osm&quot;: {
          &quot;railway&quot;: &quot;station&quot;
        }
      }
    },
    &quot;known&quot;: {
      &quot;ASD&quot;: &quot;n46419880&quot;
    }
  },
  &quot;nodes&quot;: [
    {
      &quot;id&quot;: &quot;ASD&quot;,
      &quot;name&quot;: &quot;Amsterdam Centraal&quot;,
      &quot;modalities&quot;: [&quot;rail&quot;],
      &quot;geom&quot; : {
        &quot;type&quot;: &quot;Point&quot;,
        &quot;coordinates&quot; : [
          4.9002776,
          52.378887
        ]
      },
      &quot;data&quot; : {
        &quot;naam_lang&quot;: &quot;Amsterdam Centraal&quot;,   
        &quot;code&quot;: &quot;ASD&quot;
      }
    }
  ]
}
</pre>