require 'json'
require "#{::Rails.root.to_s}/lib/geolibs/conversions"
require 'backports'

module Geoipsum
    
  class Geoipsum
  

    def initialize options
    
      @perimeter = options["perimeter"].to_f #of polygon
      #@vertices = @perimeter * 0.1 #get sensible number of vertices
      @vertices = 50 
      @bearing_range = options["bearing_range"].to_f #used to determine jaggyness of polygon
      @polygon_number = options["polygon_number"].to_i     
      @polygon_number = 500 if @polygon_number > 500 #limit the number of polygons to stop the server being hammered
      
      @bb = options["bb"].split(",") #n,w,s,e
    
      #need some extra stuff from these choices
      @mean_step_length = @perimeter / @vertices
    
      #get bearing bin width
      @deg_width = 360.0 / @vertices
      
    end
  
  
    #todo: vary the bearing range over the series of polygon to account for different distributions (so randomly select within the distribution- i.e.  minimal range would lead to straight lines- this would force drastically differing shaped polygons)
  
  
    def generate_polygons 
  
      #container to hold the full file
      geojson = {"type" => "FeatureCollection"}
    
      #array to hold the features
      features = []
     
      #fill in the polygons
      (0..@polygon_number-3).each do |feature|
        
        
        #generate random start position inside the bounding box
        xmin = @bb[1].to_f
        xmax = @bb[3].to_f
        ymin = @bb[0].to_f
        ymax = @bb[2].to_f
       
        #puts @bb
       
        ran_x = Random.new.rand(xmin..xmax)
        ran_y = Random.new.rand(ymin..ymax)
      
        start_location = [ran_x, ran_y]
        
        #puts "x: #{start_location[0]}  y: #{start_location[1]}"
        
                        
        features << {"type" => "Feature",
                             "geometry" => generate_polygon(start_location), 
                             "properties" => {"p_id" => feature.to_s}}  
      
                   
      end
    
      geojson["features"] = features
      geojson
      
    end
  
  
    #start location is [x,y]
    def generate_polygon start_location
    
      #grab 1st point
      p1 = start_location     
      start_bearing = 0.0
    
      #add point to point array
      line_string = [p1]
    
      #two less vertices to try and avoid serious overlap or teardrop shaped polygons
      #todo: test for self intersections- poss ffi geo type thingy
      (0..(@vertices-2)).each do |point|
     
        #randomly choose distance based on mean step_length and 10% of step length
        step_distance = rand(@mean_step_length*2) + (@mean_step_length - (@mean_step_length*0.01)) 
      
        step_bearing = ((start_bearing - (@bearing_range/2)).bearing + rand(@bearing_range)).bearing
      
        #add next point to line string
        line_string << ll_from_dist_bearing(step_distance, 
                                            step_bearing, 
                                            line_string[point][1], 
                                            line_string[point][0])
      
        start_bearing = (start_bearing + @deg_width).to_f.bearing
      
      end
      
      #add last point to join up the polygon
      line_string << p1
    
      #todo:  need to look into converting the geojson into other formats (could use ogr2ogr or rgeo - 
    
      geojson = {"type" => "Polygon",
                 "coordinates" => [line_string]}
    
    
    end
  
    # calculate new long and lat based on distance bearing and original long and lat - ported from js version in
    # http://www.movable-type.co.uk/scripts/latlong.html
    # bearing is in decimal degrees running from 0 to 360 or 0-180/-180
    # distance in km
    # lat long in decimal degrees

    def ll_from_dist_bearing dist, brng, lat1, lon1
      r = 6371.0
      dist = dist.to_f/r;  # dist = angular distance covered on earth's surface
      #convert all to radians
      lat1 = lat1.to_f.to_rads
      lon1 = lon1.to_f.to_rads
      brng = brng.to_f.to_rads
      #do the maths
      lat2 = Math.asin( Math.sin(lat1)*Math.cos(dist) +
             Math.cos(lat1)*Math.sin(dist)*Math.cos(brng))
             
      lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(dist)*Math.cos(lat1), 
             Math.cos(dist)-Math.sin(lat1)*Math.sin(lat2))
             
      lon2 = (lon2+3*Math::PI)%(2*Math::PI) - Math::PI
      #lat/long array output
      [lon2.to_degs, lat2.to_degs] 
    end
  
  end

end
