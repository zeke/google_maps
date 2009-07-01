module GoogleMap

  class Polyline
    attr_accessor :dom_id,
                  :map,
                  :points,
                  :color,
                  :weight

    def initialize(options)
      self.color = '#000000'
      self.weight = 1
      options.each_pair { |key, value| send("#{key}=", value) }
      
      if !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set lat, lng, and map for GoogleMapMarker."
      end
      if dom_id.blank?
        # This needs self to set the attr_accessor, why?
        self.dom_id = "#{map.dom_id}"
      end
    end
        
    def to_js
      js = []
      js << "var polyOptions = {geodesic:true};"
      js << "var polyline = new GPolyline(["
      
      self.points.each do |p|
        js << "#{p.to_js}#{ self.points.last == p ? '' : ',' }"
      end
      
      js << "], '#{self.color}', #{self.weight}, 1, polyOptions);"
      js << "#{map.dom_id}.addOverlay(polyline);"
      
      return js.join("\n")  	
    end
    
  end

end