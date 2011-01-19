jQuery.noConflict();
var $j = jQuery;			
var po = org.polymaps;
var hn = window.location.hostname;

alert(hn);
var map = po.map()
    .container(document.getElementById("inner").appendChild(po.svg("svg")))
    .center({lat: 52, lon: -2})
    .zoom(5)
    .add(po.interact())
	.on("move", move);

map.add(po.image()
    .url(po.url("http://{S}tile.cloudmade.com"
    + "/1a1b06b230af4efdbb989ea99e9841af" // http://cloudmade.com/register
    + "/4876/256/{Z}/{X}/{Y}.png")
    .hosts(["a.", "b.", "c.", ""])));

map.add(po.grid());
var previous_loc = map.extent()[0];
var layer;
add_layer();
	
	$j(document).ready(function(){
		$j("#geolink").html("get the geojson <a href='" + georef + "'>here</p>");
	});	
	
function add_layer(){
	
	if (layer != null){
			map.remove(layer);
	}

	var sw_ne = Math.round(map.extent()[0].lat * 100)/100 + "," +
	 			Math.round(map.extent()[0].lon * 100)/100 + "," + 
				Math.round(map.extent()[1].lat * 100)/100 + "," +  
				Math.round(map.extent()[1].lon * 100)/100;
	georef = "http://" + hn + "/polygons.json?perimeter=300&bearing_range=70&polygon_number=30&bb="+sw_ne			
	layer = po.geoJson().url(georef);
	map.add(layer);
	$j("#geolink").html("get the <a href='" + georef + "'>geojson</p>");
	
}
function move(){
	//test for rough distance panned so it doesn't constantly call the geoipsum service
	$j(document).ready(function(){
		//get height dist
		var y_dist = Math.abs(map.extent()[0].lat - previous_loc.lat);
		//get width dist
		var x_dist = Math.abs(map.extent()[0].lon - previous_loc.lon);
		//get hypot
		var dist = Math.sqrt(x_dist^2 + y_dist^2);
	
		if (dist > 2){					
			previous_loc = map.extent()[0];
			add_layer();		
		}			
	});			
}