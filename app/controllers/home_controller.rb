require "#{RAILS_ROOT}/lib/geolibs/geoipsum"

class HomeController < ApplicationController
  
  respond_to :html, :xml, :json
  def index
    
      params = {"perimeter"=>1000, 
                "vertices"=>30, 
                "bearing_range"=>50, 
                "polygon_number"=>20, 
                "start_location"=> [0,2]} if params.nil?
    
     randompolys = Geoipsum::Geoipsum.new(params)
     geojson = randompolys.generate_polygons
     
     
     respond_with (geojson)
     # respond_to do |format|
     #        format.json  { render :json => geojson }
     #      end
    
    
  end

end
