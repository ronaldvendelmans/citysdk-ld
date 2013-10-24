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
             .attr("transform", "translate(" + 200 + "," + 200 + ")");
   		  
   	console.log("graphsD3 innited");	  
  }
  
  setStreamGraph = function(dataLayer){
    console.log("setting stream graph");
    //2009,2010,2011,2012,2013,2015,2020,2025,2030,2035

    //var formatPercent = d3.format(".0%");

    var x = d3.scale.ordinal()
        .rangeRoundBands([0, width], .1);

    var y = d3.scale.linear()
        .range([height, 0]);

    var xAxis = d3.svg.axis()
        .scale(x)
        .orient("bottom");

    var yAxis = d3.svg.axis()
        .scale(y)
        .orient("left");
        //.tickFormat(formatPercent);
        
        

    //d3.csv("data/oens/csv/2013_stadsdelen_01_bevolking_2009-2013.csv", function(d) 
    var dataSdk=dataLayer.data;
    dataLayer.data.forEach(function(d, i){
      d.layers.oens.layers.bevolking_2035["2013"]=+d.layers.oens.layers.bevolking_2035["2013"];
      console.log("index ="+i+" layers ="+d.layers.oens.layers.bevolking_2035["2013"]);
    });

    d3.csv("data/oens/csv/2013_stadsdelen_01_bevolking_2009-2013.csv", type, function(error, data) {
      //console.log(data);
      
      x.domain(dataSdk.map(function(d) { return d.name; }));
      y.domain([d3.min(dataSdk, function(d) { return d.layers.oens.layers.bevolking_2035["2013"]; }), d3.max(dataSdk, function(d) { return d.layers.oens.layers.bevolking_2035["2013"]; }) ]);
       

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
          .attr("y", function(d) { return y(d.layers.oens.layers.bevolking_2035["2013"]); })
          .attr("height", function(d) { return height - y(d.layers.oens.layers.bevolking_2035["2013"]); })
          .style("fill", "steelblue")
          .on("mouseover", function(d){ 
           var tipsy = $(this).tipsy({ 
               gravity: 'w', 
               html: true,
               trigger: 'hover', 
                   title: function() {
                     var string=d.name+"<br> value: "+d.layers.oens.layers.bevolking_2035["2013"];
                     return string; 
                   }
             });
             $(this).trigger("mouseover");

         });

    });

    function type(d) {
      d["2013"]= +d["2013"];
      return d;
    }
   
    
    
    
    
  }
  
  //init();
  this.init=init;
  this.setStreamGraph=setStreamGraph;
  
}