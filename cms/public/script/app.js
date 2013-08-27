
  var propertyTypes = {
    "Quantity":     "qudt:numericValue",
    "Date/Time":    "xsd:datetime",
    "Identifier":   "csdk:identifierProperty",
    "Descriptive":  "rdfs:description",
    "URI":          "xsd:anyURI",
  };

   optionsForSelect = function(a,addSel) {
     var s = '';
     if(addSel==true) {
       s='<option>select..</option>';
     }
     a.forEach(function(item) {
       s = s + "<option>" + item + '</option>'
     });
     return s;
   }
   
   addHtml = function(a,ts, i) {
     if( a.length < 25 ) {
       $('#'+ts).parent()
            .html( $('<select id="' + ts + '" name="tag_select[' + i + ']"></select>')
                    .append(
                      optionsForSelect(a)
                    )
                  );
     } else {
       $('#'+ts).parent()
            .html( $('<input></input>')
                     .attr({type : 'text', size: '14', id: ts, name: "tag_select[" + i + "]", placeholder: 'layertag'})
                     .autocomplete({ source: a })
                  );
     }
   }
   
  
   tagsForLayer = function(l,ts, i) {
    if ( availableTags[l] != null ) {
      addHtml(availableTags[l],ts, i)
      return;
    }
    
    $.ajax({
      url: '/get_layer_keys/' + l,
      type: 'get',
      success: function(data){
        obj = $.parseJSON(data)
        availableTags[l] = obj[0]["keys_for_layer"]
        addHtml(availableTags[l],ts, i)
      }
    });  
  }
  
  
  newTagSelect = function(layers) {
    
    var index = '' + $("#tagselectlist").children().length 

    var ls = $(layers).attr('name', 'layer_select[' + index + ']').change(function() {
      tagsForLayer( $(this).val(), 'tag_sel_' + index, index )
    })

    var ts = $('<input></input>').attr({type : 'text', size: '14', id: 'tag_sel_' + index, name: 'tag_select[' + index + ']', placeholder: 'layertag'}).autocomplete({
          source: availableTags['osm']
        });
        
    ts = $('<span></span>').append(ts)

    var vs = $('<input></input>').attr({type : 'text', size: '14', name: 'tag_value[' + index + ']', placeholder: 'anything'});
    
    var li = $('<li></li>').append(ls)
    li.append('&nbsp;')
    li.append('&nbsp;')
    li.append(ts).wrap('<p>')
    li.append('&nbsp;=&nbsp;')
    li.append(vs)
    li.append('&nbsp;&nbsp;')

    $("#tagselectlist").append(li)
  }
		
	function addParameter(url,key,value) {
	  var a = url.split('?')
	  if(a.length>1)
	    return url + "&" + key + "=" + value;
	  else
	    return url + "?" + key + "=" + value;
	}

	function layerSelect(e) {
	  document.location = '/layers?category=' + e.value; 
	}


	function delUrl(url,params,upd) {
	  var r=confirm("Are your sure your want to delete this layer? The layer and *all* associated data will be lost...")
	  if (r==true) {
	    var nu = url;
      
      $('#delurl').html('<img height="18" width="18" src="/css/img/progress.gif">'); 
      
      if(params) {
  	    $.each(params, function(index, value) {
  	      nu = addParameter(nu,index,value);
  	    }); 
      }
    
	    $.ajax({
	      url: nu,
	      type: 'delete',
	      success: function(data){
	        $(upd).html(data);
	      }
	    });  
	  }
	}



	function csvUpload(l,u) {
	  var data = new FormData();     
	  jQuery.each($("input[type='file']")[0].files, function(i, file) {
	      data.append(i, file);
	  });
	  $.ajax({
	      type: 'post',
	      data: data,
	      url: '/layer/' + l + '/loadcsv',
	      cache: false,
	      contentType: false,
	      processData: false,
	      success: function(data){
	        $(u).html(data)
	      },
	      error: function(jqXHR,textStatus,errorThrown ){
	        $(u).html(errorThrown + '<br/>' + jqXHR.responseText)
	      }
	  });
	}

  function postData(layerid,update_rate,wsurl,toupdate) {
    
  }
  
  var loadFieldDef = function(field) {
    if($.layerProperties[field] != undefined) {
      $("#relation_desc").val($.layerProperties[field].descr)
      $("#relation_type").val($.layerProperties[field].type)
      $("#relation_lang").val($.layerProperties[field].lang)
      $("#relation_unit").val($.layerProperties[field].unit)
    } else {
      $("#relation_desc").val('')
      $("#relation_type").val('')
      $("#relation_lang").val('')
      $("#relation_unit").val('')
    }
      
  }
  
  selectFieldType = function(s) {
    console.info(s)
    
   $("#relation_type").val(propertyTypes[s])
   
   if(s=='Quantity') {
     $("#relationunit").show()
   } else {
     $("#relationunit").hide()
   }
   
   if(s=='Descriptive') {
     $("#relationlang").show()
   } else {
     $("#relationlang").hide()
   }
  }
  
  selectFieldTags = function(layer,fieldselect) {
    if ( availableTags[layer] != null ) {
      $('#ldmap')
           .prepend( $('<select id="' + fieldselect + '" name="field" onchange="loadFieldDef(this.value)"></select>')
                   .append(
                     optionsForSelect(availableTags[layer],false)
                   )
                 );
      return;
    }
    
    $.ajax({
      url: '/get_layer_keys/' + layer,
      type: 'get',
      success: function(data){
        obj = $.parseJSON(data)
        availableTags[layer] = obj[0]["keys_for_layer"]
        return selectFieldTags(layer,fieldselect)
      }
    });  
    
  }
  

  
  
  