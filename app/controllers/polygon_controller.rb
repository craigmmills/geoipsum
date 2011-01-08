class PolygonController < ApplicationController
  respond_to :html, :xml, :json
  def index
    puts params
    
    randompolys = Geoipsum::Geoipsum.new(params)
    geojson = randompolys.generate_polygons
    respond_with (geojson)

  end

end
