require "#{Rails.root.to_s}/lib/geolibs/geoipsum"

class PolygonController < ApplicationController
  respond_to :json
  def index
    #puts params
    
    randompolys = Geoipsum::Geoipsum.new(params)
    geojson = randompolys.generate_polygons
    respond_with (geojson)

  end

end
