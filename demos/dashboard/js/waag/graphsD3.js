WAAG.GraphsD3 = function GraphsD3() {
  console.log("graphsD3 constructor");
  //var svg, streamGraph;
  
  var margin = {top: 20, right: 20, bottom: 30, left: 40},
      width = 960 - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

  function init(svg){

    // 
    streamGraph=svg.append("g")
             .attr("id", "streamGraph")
             .attr("class", "Oranges")
             .attr("transform", "translate(" + 200 + "," + 100 + ")");
   		  
   	console.log("graphsD3 innited");	  
  }
  
  setStreamGraph = function(dataLayer){
    console.log("setting stream graph");
    //2009,2010,2011,2012,2013,2015,2020,2025,2030,2035

    //var formatPercent = d3.format(".0%");

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);
        

    // var y = d3.scale.linear()
    //     .range([height, 0]);
    var y = d3.scale.linear()
        .rangeRound([height, 0]);    

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");
        //.tickFormat(formatPercent);
        
    var color = d3.scale.category10();
    //var color = d3.scale.ordinal().range(["#98abc5", "#8a89a6", "#7b6888", "#6b486b", "#a05d56", "#d0743c", "#ff8c00"]);    
 
    var dataSdk=dataLayer.data;
    
    var years = d3.keys(dataSdk[0].layers.oens.layers.bevolking_2035).filter(function(key) { 
        if(key == "mannen" || key == "vrouwen" || key == "bc/std"){
          //do nothing
        } else{
          return key;
        }  
    });
    
    dataSdk.forEach(function(d, i) {
          d.layers.oens.layers.bevolking_2035_multi = d.layers.oens.layers.bevolking_2035;
          d.layers.oens.layers.bevolking_2035 = years.map(function(year) { return {year: year, name:d.name, value: +d.layers.oens.layers.bevolking_2035[year]}; });

    });

    
    //color.domain(d3.keys(data[0]).filter(function(key) { return key !== "date"; }));
    color.domain(d3.keys(dataSdk[0].layers.oens.layers.bevolking_2035_multi).filter(function(key) { 
        if(key == "mannen" || key == "vrouwen" || key == "bc/std"){
          //do nothing
        } else{
          return key;
        }  
    })
    );
    
    var years = color.domain().map(function(year) {
        //console.log(year);
        return {
          year: year,
          values: dataSdk.map(function(d) {
            return {name: d.name, value: +d.layers.oens.layers.bevolking_2035_multi[year]};
          })
        };
      });
    

    console.log(years);
    
    var line = d3.svg.line()
        .interpolate("basis")
        .x(function(d) { return x(d.name); })
        .y(function(d) { return y(d.value); });
      
    x.domain(dataSdk.map(function(d) { return d.name; }));
    y.domain([
      d3.min(dataSdk, function(c) { return d3.min(c.layers.oens.layers.bevolking_2035, function(v) { return v.value; }); }),
      d3.max(dataSdk, function(c) { return d3.max(c.layers.oens.layers.bevolking_2035, function(v) { return v.value; }); })
    ]);
    
       

    streamGraph.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + height + ")")
            .call(xAxis)
            .attr("font-family", "sans-serif")
            .attr("font-size", "10px")
            .attr("fill", "#666")
            
    
    streamGraph.append("g")
          .attr("class", "y axis")
          .call(yAxis)
        .append("text")
          .attr("transform", "rotate(-90)")
          .attr("y", 6)
          .attr("dy", ".71em")
          .attr("font-family", "sans-serif")
          .attr("font-size", "10px")
          .attr("fill", "#666")
          .style("text-anchor", "end")
          .text("Aantal inwoners");
 
    streamGraph.selectAll(".bar")
              .data(dataSdk)
            .enter().append("rect")
              .attr("class", "bar")
              .attr("x", function(d) { return x(d.name); })
              .attr("width", x.rangeBand())
              .attr("y", function(d, i) { return y(d.layers.oens.layers.bevolking_2035[0].value); })
              .attr("height", function(d) { return height - y(d.layers.oens.layers.bevolking_2035[0].value); })
              .style("fill", "steelblue")
              .on("mouseover", function(d){ 
               var tipsy = $(this).tipsy({ 
                   gravity: 'w', 
                   html: true,
                   trigger: 'hover', 
                       title: function() {
                         var string=d.name+"<br> value: "+d.layers.oens.layers.bevolking_2035[0].value;
                         return string; 
                       }
                 });
                 $(this).trigger("mouseover");
        
             });

         var year = streamGraph.selectAll(".year")
               .data(years)
             .enter().append("g")
               .attr("class", "city");
         
         year.append("path")
               .attr("class", "line")
               .attr("d", function(d) { return line(d.values); })
               .style("stroke", function(d) { return color(d.year); })
               .style("fill", "none")
               .on("mouseover", function(d){ 
                var tipsy = $(this).tipsy({ 
                    gravity: 'w', 
                    html: true,
                    trigger: 'hover', 
                        title: function() {
                          var string=d.year;
                          return string; 
                        }
                  });
                  $(this).trigger("mouseover");

              });;



    function type(d) {
      d["2013"]= +d["2013"];
      return d;
    }
   
    
    
    
    
  }
  
  //init();
  this.init=init;
  this.setStreamGraph=setStreamGraph;
  
}