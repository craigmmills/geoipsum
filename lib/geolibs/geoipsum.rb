require './conversions'
require 'ffi-geos'
require 'json'

  #1st job- create simple triangular polygon with rgeo
  
  
  #get starting point
  #move to next point
  #move to bext point
  #collect final point 
  
  #construct linestring
  #parse into multipolygon
  
  
  
  
  #NB hold each geom type in an array so they can be tested against each other for self intersects.
  
  #one idea would be to extend teh ffi-geos point type to use as the first point
  
class Geoipsum
  
  #probably will use options for this- it would be nice to pass in a hash of starting lonlat
  def initialize perimeter, vertices, bearing_range
    
    @perimeter = perimeter.to_f
    @vertices = vertices.to_f
    @bearing_range = bearing_range.to_f
    
    #need some extra stuff from these choices
    @mean_step_length = @perimeter / @vertices
    
    #get bearing bin width
    @deg_width = 360.0 / @vertices
    
    
    
  end
  
  
  #todo: vary the bearing range over the series of polygon to account for different distributions (so randomly select within the distribution- i.e.  minimal range would lead to straight lines)
  
  
  def generate
    
    #grab 1st point
    puts "bearing range = #{@bearing_range}; perimeter = #{@perimeter}; vertices = #{@vertices}; mean step length = #{@mean_step_length}"
    
    p1 = [0,2]  #todo create user defined start point
    start_bearing = 0.0
    
    #add point to point array
    line_string = [p1]
    
    #one less vertices to try and avoid serious overlap
    (0..(@vertices-1)).each do |point|
      puts point
      #set distance and bearing
      
      #randomly choose distance based on mean step_length +/- 20km
      step_distance = rand(40) + (@mean_step_length - 20) #todo, allow user to choose the range
      
      puts step_distance
      step_bearing = ((start_bearing - (@bearing_range/2)).bearing + rand(@bearing_range)).bearing
      
      #add next point to line string
      line_string << ll_from_dist_bearing(step_distance, step_bearing, line_string[point][0], line_string[point][1])
      
      start_bearing = (start_bearing + @deg_width).to_f.bearing
      puts "start bearing: #{start_bearing}"
    end
    
    
    line_string << p1
    reader = Geos::WktReader.new  
        #todo:  need to look into converting the geojson into other formats (could use ogr2ogr or rgeo - ideally need an ffi-gdal to make the conversion)
        
        
    #pg = reader.read("POLYGON((#{line_string.collect{|point| point.join(" ")}.join(",")}))")
    wkt = "POLYGON((#{line_string.collect{|point| point.join(" ")}.join(",")}))"
    geojson = "{ \"type\": \"Polygon\",\"coordinates\": [#{line_string.to_json}]}"
    
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
    lat2 = Math.asin( Math.sin(lat1)*Math.cos(dist) +                           Math.cos(lat1)*Math.sin(dist)*Math.cos(brng))
    lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(dist)*Math.cos(lat1), Math.cos(dist)-Math.sin(lat1)*Math.sin(lat2))
    lon2 = (lon2+3*Math::PI)%(2*Math::PI) - Math::PI
    #lat/long array output
    [lat2.rads, lon2.rads] 
  end
  
end
