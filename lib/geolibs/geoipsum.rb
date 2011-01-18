#require 'ffi-geos'
require 'json'
require "#{::Rails.root.to_s}/lib/geolibs/conversions"

  
  #reminder-  hold each geom type in an array so they can be tested against each other for self intersects.
  

module Geoipsum
  

  
  class Geoipsum
  

    def initialize options
    
      @perimeter = options["perimeter"].to_f
      @vertices = @perimeter * 0.1
      @bearing_range = options["bearing_range"].to_f
      @polygon_number = options["polygon_number"].to_i
      @bb = options["bb"].split(",") #n,w,s,e
      
      
      
      
    
      #need some extra stuff from these choices
      @mean_step_length = @perimeter / @vertices
    
      #get bearing bin width
      @deg_width = 360.0 / @vertices
      
    
    
    end
  
  
    #todo: vary the bearing range over the series of polygon to account for different distributions (so randomly select within 
    #the distribution- i.e.  minimal range would lead to straight lines- this would force drastically differing shaped polygons)
  
    def generate_polygons 
  
      #container to hold the full file
      geojson = {"type" => "FeatureCollection"}
    
      #array to hold the features
      features = []
     
    
      (0..@polygon_number-3).each do |feature|
        
        
        #generate random start position inside the bounding box
        xmin = @bb[1].to_f
        xmax = @bb[3].to_f
        ymin = @bb[0].to_f
        ymax = @bb[2].to_f
        
        new_coordx = rand(xmax - xmin) + xmin
        new_coordy = rand(ymax - ymin) + ymin
        
        puts @bb
        puts "y: #{new_coordy}     x: #{new_coordx}"
        
        @start_location = [new_coordx, new_coordy]
        
        
                         
        features << {"type" => "Feature",
                             "geometry" => generate_polygon(@start_location), 
                             "properties" => {"p_id" => feature.to_s}}  
              
        
       
        # point = {"type" => "Point",
        #                   "coordinates" => @start_location}
        
        # features << {"type" => "Feature",
        #                      "geometry" => point, 
        #                      "properties" => {"p_id" => feature.to_s}}  
                        

        
        #get next polygon position
        #random distance between perimeter/2 and perimeter * 10
      
                   
      end
    
      geojson["features"] = features
      geojson
      
    end
  
  
    #start location is [x,y]
    def generate_polygon start_location
    
      #grab 1st point
      #puts "bearing range = #{@bearing_range}; perimeter = #{@perimeter}; vertices = #{@vertices}; mean step length = 
      #{@mean_step_length}"
    
      p1 = start_location  #todo create user defined start point
      start_bearing = 0.0
    
      #add point to point array
      line_string = [p1]
    
      #one less vertices to try and avoid serious overlap
      (0..(@vertices-2)).each do |point|
     
        #set distance and bearing
      
        #randomly choose distance based on mean step_length +/- 20km
        step_distance = rand(@mean_step_length*2) + (@mean_step_length - (@mean_step_length*0.01)) #todo, allow user to choose the range
      
        step_bearing = ((start_bearing - (@bearing_range/2)).bearing + rand(@bearing_range)).bearing
      
        #add next point to line string
        line_string << ll_from_dist_bearing(step_distance, 
                                            step_bearing, 
                                            line_string[point][1], 
                                            line_string[point][0])
      
        start_bearing = (start_bearing + @deg_width).to_f.bearing
      
      end
    
    
      line_string << p1
    
      #todo:  need to look into converting the geojson into other formats (could use ogr2ogr or rgeo - 
      #ideally need an ffi-gdal to make the conversion)
        
      #reader = Geos::WktReader.new      
      #pg = reader.read("POLYGON((#{line_string.collect{|point| point.join(" ")}.join(",")}))")
      #wkt = "POLYGON((#{line_string.collect{|point| point.join(" ")}.join(",")}))"
    
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
      lat1 = lat1.to_f.degrees
      lon1 = lon1.to_f.degrees
      brng = brng.to_f.degrees
      #do the maths
      lat2 = Math.asin( Math.sin(lat1)*Math.cos(dist) +
             Math.cos(lat1)*Math.sin(dist)*Math.cos(brng))
             
      lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(dist)*Math.cos(lat1), 
             Math.cos(dist)-Math.sin(lat1)*Math.sin(lat2))
             
      lon2 = (lon2+3*Math::PI)%(2*Math::PI) - Math::PI
      #lat/long array output
      [lon2.rads, lat2.rads] 
    end
  
  end

end
