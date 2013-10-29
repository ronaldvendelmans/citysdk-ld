var WAAG = WAAG || {};
var fontBlue="#80BFFF";
var wMap=1024;
var hMap=768;
WAAG.GeoMap = function GeoMap(container) {

	var mapScale=200000;
	var svg, projection, path, map, regionMap, lineMap, dotMap, customLabelMap, barChart, streamGraph, circlePack;
	var centered, zoom;
	var nodeTextCloud;
	var defs, filter, feMerge;
	var rangeCB=9; //range colorbrewer
	var mapOffset=0.75;
	var tTime=500;
	var geoScaling=false;
	var feedBack;
	
	var activeLayer="bev_dichth";
	var activeDataLayer;
	
	console.log("map constructor innited");

	function init(){
		wMap=window.innerWidth;
		hMap=window.innerHeight;
		
		if(wMap<1200){
		  wMap=1200;
		  //mapScale=mapScale*(window.innerWidth/1200);
	  }
	  
	  mapScale=mapScale/2;
	
		$(container).css({
				'position':"absolute",
				'left':0+"px",
			  'top':0+"px",
				'width':wMap+"px",
			  'height':hMap+"px",
			  'z-index':0
			});
	
		projection = d3.geo.mercator()
			     .translate([ (wMap/2) , (hMap/2) ])
			     .scale([mapScale]);
		
		projection.center([4.9000,52.3725])

		path = d3.geo.path()
		      .projection(projection)
		      .pointRadius(10);
		      
		zoom = d3.behavior.zoom()
        .translate([0, 0])
        .scale(1)
        .scaleExtent([0.05, 18])
        .on("zoom", zoomed);

		//create svg element            
		svg = d3.select(container).append("svg")
		    .attr("width", wMap)
		    .attr("height", hMap)
		    .style("fill", "white")
		    .call(zoom);   
		    		    
		map = svg.append("g")
		   .attr("id", "map");
		   
	
	// set dropshadow filters	   
   defs = map.append("defs");
   
   filter = defs.append("filter")
         .attr("id", "dropshadow")
   
     filter.append("feGaussianBlur")
         .attr("in", "SourceAlpha")
         .attr("stdDeviation", 1)
         .attr("result", "blur");
     filter.append("feOffset")
         .attr("in", "blur")
         .attr("dx", 0.5)
         .attr("dy", 0.5)
         .attr("result", "offsetBlur");
   
     feMerge = filter.append("feMerge");
   
     feMerge.append("feMergeNode")
         .attr("in", "offsetBlur")
     feMerge.append("feMergeNode")
         .attr("in", "SourceGraphic");		   

    // layerd geo maps
		regionMap=map.append("g")
		   .attr("id", "regionMap");
		   
		regionMap.append("g")
		  .attr("id", "main_map")
		  .attr("class", "Oranges"); //colorBrewer   
		
	  regionMap.append("g")
		  .attr("id", "cbs")
		  .attr("class", "Oranges"); //colorBrewer
				   	   
   	lineMap=map.append("g")
		   .attr("id", "divv_trafficflow")
		   .attr("transform", "translate("+ -1000 +",0)")
		      
		dotMap=map.append("g")
		   .attr("id", "divv_taxis")
		   .attr("transform", "translate("+ -1000 +",0)")
		   .attr("class", "Oranges"); //colorBrewer  
		   
		customLabelMap=map.append("g")
   		  .attr("id", "customLabelMap");
   		  
   	barChart=svg.append("g")
   		  .attr("id", "barChartMain");
        
    barChart.append("g")
		  .attr("id", "barChart")
		  .attr("class", "Oranges"); //colorBrewer   
		 
		barChart.append("g")
		  .attr("id", "legenda")
		  .attr("class", "Oranges"); //colorBrewer
		  
  	
		
    // var d = d3.select(container)
    //       .append("div")
    //     .attr("id", "feedBack")
    //     .style("top", 0+"px")
    //     .text("append divje");

     //Import the plane
     d3.xml("svg/text_cloud.svg", "image/svg+xml", function(xml) {  
       nodeTextCloud = document.importNode(xml.documentElement, true);
        
     });
     
    graphsD3.init(svg);  

		repository.initRepository();

	}

	preProcesData = function(dataLayer){
    var equals=0;
    console.log("preproces dataLayer ="+dataLayer.layer);
    dataLayer.data.sort(function(a, b) { return d3.ascending(a.cdk_id, b.cdk_id)});
    
    // rewrite results to geojson
      dataLayer.data.forEach(function(d){
        // redefine data structure for d3.geom
        if(dataLayer.geom){
         
        	d.type="Feature";
    			d.geometry=d.geom;
    			delete d.geom;
    			d.centroid = path.centroid(d);
    			d.bounds= path.bounds(d);
    			
        }

        // set data values for visualisation    
        if(dataLayer.layer=="cbs" || dataLayer.layer=="main_map"){
          d.subData=d.layers.cbs.data;  
        }
                


    	});

    	// set legenda object data
      dataLayer.legenda={};
    	for (var i=0; i<rangeCB; i++){ 	    
    	    dataLayer.legenda["q"+i]=0;
    	    dataLayer.legenda["q"+i].max=0;
    	    dataLayer.legenda["q"+i].min=0;
    	       
    	}
    	

	  if(dataLayer.layer=="main_map" && dataLayer.label=="Nederland"){
	    console.log("creating main map");
	    
	    createMainMap(dataLayer);
	  }else if(dataLayer.layer=="divv_trafficflow"){
	      updateDivvTrafficMap(dataLayer);
	      console.log("adding layer divv trafficflow");
    }else if(dataLayer.layer=="divv_taxis"){
        updateDivvMapTaxies(dataLayer);
	      console.log("adding layer divv taxis");    
	  }else{
	    activeDataLayer=dataLayer;
	    updateDataSet(dataLayer);
	    console.log("updating data set "+dataLayer.cdk_id);  
	  }
    

  }

  createMainMap = function (dataLayer){
    // set d3 visualisations
    
      var colorFill="#f8ffff";
      
      var vis=d3.select("#"+dataLayer.layer);
      
      console.log("adding main map");
      vis.selectAll("path")
    			.data(dataLayer.data)
    			.enter().append("path")
    			  .attr("id", function(d, i){return d.cdk_id;})
    			  .attr("d", path)
    			  //.style("fill", "#fff")
    			  //.style("stroke", "none")
    			  .style("opacity", 0.1)
    			  .style("stroke-width", 0.5+"px")
    			  .on("mouseover", function(d){
    			    d3.select(this).attr("class", "q1-9").style("opacity", 0.25).style("stroke-width", 1+"px" )  

      				var tipsy = $(this).tipsy({ 
      						gravity: 'w', 
      						html: true,
      						trigger: 'hover', 
      				        title: function() {
      				          var string=d.name;
      				          return string; 
      				        }
      					});
      					$(this).trigger("mouseover");

      			})
      			.on("mouseout", function(d){
      			  d3.select(this).attr("class", "q-white").style("opacity", 0.1).style("stroke-width", 0.5+"px" );

      			})
    			  .on("click", function(d){
    			    var level=5;
    			    if(d.cdk_id=="admr.nl.amsterdam"){
    			      level=5;
    			      
    			    };
    			    console.log("get new data "+d.cdk_id+" --> "+d.name+" --> level "+level);
    			    repository.getCbsData(d.cdk_id, d.name, level);
    			    repository.getDivvData(d.cdk_id);
    			        			    
      			})
      	
        var initMenu = menu.createMenuItems(dataLayer);
        menu.updateListView(activeLayer);		
    		console.log("main map innited");
    		arrangeZindex();

      // kick off map through CitySdk  
      //repository.getCbsData("admr.nl.amsterdam", "Amsterdam", 4);
      //repository.getCbsData("admr.nl.nederland", "Nederland", 3);

      // kick off preloaded data (stored on server)
      var newLayer={cdk_id:"admr.nl.nederland", apiCall:"/regions?admr::admn_level=3&layer=cbs&geom", data:dataLayer.data, geom:"regions", layer:"cbs", label:"Nederland"};
      newLayer.legenda={};
    	for (var i=0; i<rangeCB; i++){ 	    
    	    newLayer.legenda["q"+i]=0;
    	    newLayer.legenda["q"+i].max=0;
    	    newLayer.legenda["q"+i].min=0;
    	       
    	}
      activeDataLayer=newLayer;
      repository.setCbsNlMap(newLayer);
        
  };
  
  var max, colorScale, quantizeBrewer, scalingGeoGeo;
  updateDataSet = function (dataLayer){
    
    if(activeDataLayer.cdk_id!=dataLayer.cdk_id){
      activeDataLayer=dataLayer;
    }
    
    dataLayer.data.forEach(function(d){
	    d.subData[activeLayer]=parseFloat(d.subData[activeLayer]);     
      if(d.subData[activeLayer]<0 || isNaN(d.subData[activeLayer]) ){
          d.subData[activeLayer]=0;
      };
    });
    
    dataLayer.data.sort(function(b, a) { return d3.ascending(a.subData[activeLayer], b.subData[activeLayer])});

    max =  d3.max(dataLayer.data, function(d) { return d.subData[activeLayer]; });
	  colorScale = d3.scale.linear().domain([0,max]).range(['white', 'orange']);
    quantizeBrewer = d3.scale.quantile().domain([0, max]).range(d3.range(rangeCB));
    scalingGeo = d3.scale.linear().domain([0, max]).range(d3.range(max));

    updateRegionsMap(dataLayer);
    updateBarChart(dataLayer);
    updateCirclePack(dataLayer);
    
  }
  
   updateRegionsMap = function (dataLayer){
      
   //var data=dataLayer.data;
    //dataLayer.data.sort(function(a, b) { return d3.ascending(a.subData[activeLayer], b.subData[activeLayer])});
    var layerLabel;
    for(var i=0; i<cbsLayers.length; i++){
      if(activeLayer==cbsLayers[i].value){
        layerLabel=cbsLayers[i].description;
      }
    }
    
    d3.select("#legenda-header").text(dataLayer.layer+" - "+dataLayer.label+" - "+activeLayer);
    menu.updateListIcons(activeLayer);
         
    var visCBS=d3.select("#"+dataLayer.layer);
    var vis=visCBS.selectAll("path").data(dataLayer.data, function(d, i){return d.cdk_id})
     
    vis.enter().append("path")
           .attr("id", function(d, i){return d.cdk_id})
           .attr("d", path)
           .attr("class", function(d) { return "q" + quantizeBrewer([d.subData[activeLayer]]) + "-9"; }) //colorBrewer
           //.style("stroke-width", 0.1+"px")
           .style("opacity", 1)
            .on("mouseover", function(d){ 
             d.className=$(this).attr("class");
             d3.select(this).style("stroke-width", 0.5+"px" );
             var tipsy = $(this).tipsy({ 
                 gravity: 'w', 
                 html: true,
                 trigger: 'hover', 
                     title: function() {
                       var string=d.name+"<br> value: "+d.subData[activeLayer];
                       return string; 
                     }
               });
               $(this).trigger("mouseover");
  
           })
           .on("mouseout", function(d){
             d3.select(this).style("stroke-width", 0.1+"px" );
           })
           .on("click", function(d){
            //console.log("data stored :"+d);
            if(dataLayer.cdk_id=="admr.nl.nederland"){
              repository.getCbsData(d.cdk_id, d.name, 5);
              
              // if(d.name=="Amsterdam"){
              //                 repository.getDivvData(d.cdk_id);
              //               }
              
              console.log("d.name ="+d.name);
            } 
   			    repository.getDivvData(d.cdk_id);
   			        			    
     			})
      
      vis.attr("class", function(d) { return "q" + quantizeBrewer([d.subData[activeLayer]]) + "-9"; }) //colorBrewer   
         
      vis.transition()
          .duration(tTime)
          .attr("transform", function(d) {
                var x = d.centroid[0];
                var y = d.centroid[1];
                //d.bounds = path.bounds(d);
                var s;         
                if(geoScaling==false){
                  s=1;
                }else{
                  s=scalingGeo([d.subData[activeLayer]]);
                }    
                return "translate(" + x + "," + y + ")"
                    + "scale(" + s + ")"
                    + "translate(" + -x + "," + -y + ")";
          })
          
           
       vis.exit().transition()
           .duration(tTime)
          .style("opacity", 0 )
          .remove();   
        
  };
  
  updateGeoScaling = function (value){
    geoScaling=value;
    //var data = activeDataLayer.data;
    var visCBS=d3.select("#cbs");
    var vis=visCBS.selectAll("path").data(activeDataLayer.data, function(d, i){return d.cdk_id});
    
    vis.transition()
        .duration(tTime/2)
        .attr("transform", function(d) {
              var x = d.centroid[0];
              var y = d.centroid[1];
              //d.bounds = path.bounds(d);
              var s;         
              if(geoScaling==false){
                s=1;
              }else{
                s=scalingGeo([d.subData[activeLayer]]);
              }    
              return "translate(" + x + "," + y + ")"
                  + "scale(" + s + ")"
                  + "translate(" + -x + "," + -y + ")";
        })
    
    
  }
  
	var mTop=40, mBottom=20, mLeft=20, mRight=40, barWidth=240, legendaWidth=10;
	function updateBarChart(dataLayer){
	  	
  	//reset leganda values
    for(var i in dataLayer.legenda) {
       dataLayer.legenda[i]=0;
    };

  	var visHeigth = ( window.innerHeight - mTop - mBottom );
  	var yPadding= visHeigth /dataLayer.data.length;
  	var barHeight= visHeigth / dataLayer.data.length;
  	if(barHeight>2)barHeight=1;
  	
  	var barsX=mLeft+legendaWidth;

    var visBars=d3.select("#barChart");
        
    var vis=visBars.selectAll("rect").data(dataLayer.data, function(d, i){return d.cdk_id})
    
    vis.enter().append("rect")
       .attr("id", function(d, i){return d.cdk_id})
       .attr("x", barsX+10)
       .attr("y", function(d, i){return (mTop+(i*yPadding) )})
       .attr("width", 0)
       .attr("height", barHeight)
       .attr("class", function(d) { 
          var q=quantizeBrewer([d.subData[activeLayer]]);
          //dataLayer.legenda["q"+q]++;
          if(d.subData[activeLayer]>dataLayer.legenda["q"+q]){
            dataLayer.legenda["q"+q]=d.subData[activeLayer];
          }
          return "q" + q + "-9"; 
        }) //colorBrewer
       .on("mouseover", function(d){ 
 				  d3.select(this).style("stroke-width", 0.5+"px" );
   				var tipsy = $(this).tipsy({ 
   						gravity: 'w', 
   						html: true,
   						trigger: 'hover', 
   				        title: function() {
   				          var string=d.name+"<br> value: "+d.subData[activeLayer];
   				          return string; 
   				        }
   					});
   					$(this).trigger("mouseover");

 			})
 			.on("mouseout", function(d){
 			  d3.select(this).style("stroke-width", 0.25+"px" );
 			})
 			
 			vis.transition()
          .duration(tTime)
          .attr("width", function(d){return scalingGeo([d.subData[activeLayer]])*barWidth})
           
       vis.exit().transition()
          .duration(tTime)
          .attr("width", 0)
          .remove();


      // legenda
      var dataLegenda=d3.entries(dataLayer.legenda);
      var yPrev=0;
      var visLegenda=d3.select("#legenda");
      var legenda=visLegenda.selectAll("rect").data(dataLegenda, function(d, i){return "q" + i + "-9"});
      
      legenda.enter().append("rect")
         .attr("x", mLeft)
         .attr("width", legendaWidth)
         .attr("height", function(d){return visHeigth/9})
         .attr("y", function(d, i){return mTop+(i*(visHeigth/9))})
         .attr("class", function(d, i) {
              return "q" + (8-i) + "-9"; 
            }) //colorBrewer
        .text("testje")
      
      // legenda.transition()
      //     .duration(tTime)
      //     .attr("y", function(d, i){
      //        var y=mTop+yPrev;
      //        yPrev+=d.value*yPadding;
      //        return y;
      //        })
      //      .attr("height", function(d){return d.value*yPadding});
     
      var legendaTxt=visLegenda.selectAll("text").data(dataLegenda, function(d, i){return "q" + i + "-9"});     
      legendaTxt.enter().append("text")
        .attr("x", mLeft-15)
        .attr("font-family", "sans-serif")
        .attr("font-size", "10px")
        .attr("fill", "#666")
        .attr("text-anchor", "right")   
        .text(function (d) { return d.value })
        
      legendaTxt.attr("y", function(d, i){return mTop+((8-i) * (visHeigth/9))+8 }) 
        .text(function (d) { return d.value })
        .attr("text-anchor", "right")  
        
        // legendaTxt.transition()
        //     .duration(tTime)
        //     .attr("y", function(d, i){
        //        var y=mTop+yPrev;
        //        yPrev+=d.value*yPadding;
        //        return y;
        //        })
 

	}
	
	updateDivvTrafficMap = function(dataLayer){

  	var data=dataLayer.data;
  	
  	data.forEach(function(d){
	     var g= d.layers["divv.traffic"];
	    
	     var tt=parseInt(g.data.traveltime);
	     var tt_ff=parseInt(g.data.traveltime_freeflow);

       //d.visData=parseInt(g.data.traveltime_freeflow);
       d.visData=tt/tt_ff;
       
       //console.log("trafel perc ="+d.visData);
       if(d.visData<0 || isNaN(d.visData) || d.visData=="Infinity"){
            d.visData=0.1;
        }
        
        d.visLabel=g.data.velocity;
    });
    
    var max =  d3.max(data, function(d) {return d.visData; });
	  
	  var color = d3.scale.linear()
            .domain([1, max])
            .range(['black', 'red']);
    
  	
  	var visTraffic=d3.select("#"+dataLayer.layer);
  	
    var vis=visTraffic.selectAll("path").data(data, function(d, i){return d.cdk_id});

		vis.enter().append("path")
  			  .attr("id", function(d, i){return d.cdk_id})
  			  .attr("d", path)
  			  .style("fill-opacity", 1)
  			  .style("stroke-width", function(d){return 0})
  			  .style("stroke", function(d) { return color(d.visData)})
  			.on("mouseover", function(d){ 
  				var tipsy = $(this).tipsy({ 
  						gravity: 'w', 
  						html: true,
  						trigger: 'hover', 
  				        title: function() {
  				          var string=d.name+"<br> value: "+d.visLabel+" km/u";
  				          return string; 
  				        }
  					});
  					$(this).trigger("mouseover");

  			})
  			.on("mouseout", function(d){ 
  				
  			});
  			
  	    vis.transition()
            .duration(500)
            .style("stroke-width", function(d){return d.visData})

         vis.exit().transition()
            .duration(250)
            .style("stroke-width", function(d){return 0})
            .remove();		  

	}
	
	
	
	updateDivvMapTaxies = function(dataLayer){
    
	  var data=dataLayer.data;
	  data.forEach(function(d){
	     var g = d.layers["divv.taxi"];
	    
       d.visData=parseInt(Math.random()*parseInt(g.data.aantal));
       
       if(d.visData<0 || isNaN(d.visData) ){
            d.visData=1;
        }
 
    });


    var max =  d3.max(data, function(d) { return d.visData; });
    
    console.log("max ="+max);
    var colorScale = d3.scale.linear().domain([0,max]).range(['white', 'blue']);
    var quantizeBrewer = d3.scale.quantile().domain([0, max]).range(d3.range(9));
    var scalingGeo = d3.scale.linear().domain([0, max]).range(d3.range(100));

  	var visTaxies=d3.select("#"+dataLayer.layer);
    var vis=visTaxies.selectAll("path").data(data, function(d, i){return d.cdk_id});

  	
		vis.enter().append("path")
  			  .attr("id", function(d, i){return d.cdk_id})
  			  .attr("d", function(d){
                        path.pointRadius(d.visData);
                        return path(d);
                      })
  			  .style("fill-opacity", 1)
  			  .style("stroke-width", 0.1+"px")
  			  .attr("class", function(d) { return "q" + quantizeBrewer([d.visData]) + "-9"; }) //colorBrewer
  			.on("mouseover", function(d){ 
  				var tipsy = $(this).tipsy({ 
  						gravity: 'w', 
  						html: true,
  						trigger: 'hover', 
  				        title: function() {
  				          var string=d.name+"<br> value: "+d.visData;
  				          return string; 
  				        }
  					});
  					$(this).trigger("mouseover");

  			})
  			.on("mouseout", function(d){ 
  				
  			})
  			.on("click", function(){updateDivvMapTaxies(dataLayer)});
  			
  			vis.attr("class", function(d) { return "q" + quantizeBrewer([d.visData]) + "-9"; }) //colorBrewer
  	    vis.transition()
            .duration(500)
            .attr("d", function(d){
                          path.pointRadius(d.visData);
                          return path(d);
                        })

         vis.exit().transition()
            .duration(250)
            .attr("d", 0)
            .remove();		
  			

	}
	
		
	function arrangeZindex(){
	  var vis;
	  var vis=d3.select("#cbs");
  	vis.moveToFront();
	  
	  var vis=d3.select("#barChart");
	  vis.moveToFront();
	}
	
	d3.selection.prototype.moveToFront = function() {
      return this.each(function(){
      this.parentNode.appendChild(this);
      });
  };

	function zoomed() {
	    //console.log(d3.event);
      map.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
  };
  
  // function click(d) {
  //   g.selectAll(".active").classed("active", false);
  //   d3.select(this).classed("active", active = d);
  // 
  //   var b = path.bounds(d);
  //   g.transition().duration(750).attr("transform",
  //       "translate(" + projection.translate() + ")"
  //       + "scale(" + .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height) + ")"
  //       + "translate(" + -(b[1][0] + b[0][0]) / 2 + "," + -(b[1][1] + b[0][1]) / 2 + ")");
  // }
  
  setActiveLayer = function(_activeLayer){
    //console.log("setting active layer "+_activeLayer);
    activeLayer=_activeLayer;
    console.log("activeDataLayer ="+activeDataLayer.layer);
    updateDataSet(activeDataLayer);
  }
  
  function updateCirclePack(dataLayer){
      
    //console.log(d);
    // var w=wMap;
    // var h=hMap;
    // var data=dataLayer.data;
    // var dataPack={children:data};
    // 
    // var pack = d3.layout.pack()
    //   .size([w, h])
    //   .value(function(d) { return d.subData[activeLayer] })
    // 
    // 
    // var node = circlePack.datum(dataPack).selectAll(".node")
    //     .data(pack.nodes)
    //     .enter().append("g")
    //     .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; })  
    //     .attr("id", "circle_pack");
    //     node.append("circle")
    //           .attr("r", function(d) { return d.r; })
    //           .style("fill-opacity", 0.1);
    //           
    //     // node.append("title")
    //     //      .text(function(d) { return d.name+"/n"+d.value});
    // 
    //     node.append("circle")
    //         .attr("r", function(d) { return d.r; }) 
    //         .style("fill-opacity", 0.5)
    //         .style("fill", function(d) { return color(d.subData[activeLayer])})
    //         //.attr("class", function(d) { return "q" + quantize([d.value]) + "-9"; })           


	  
	}
  
  

  init();
  this.updateRegionsMap=updateRegionsMap;
  this.preProcesData=preProcesData;
  this.updateDataSet=updateDataSet;
  this.setActiveLayer=setActiveLayer;
  this.updateGeoScaling=updateGeoScaling;
  this.updateDivvTrafficMap=updateDivvTrafficMap;
  this.updateDivvMapTaxies=updateDivvMapTaxies;
  return this;   

};