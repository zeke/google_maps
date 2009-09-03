module GoogleMap

  class Polyline
    #include Reloadable
    include UnbackedDomId

    attr_accessor :dom_id,
                  :map,
                  :vertices,
                  :color,
                  :weight,
                  :opacity,
                  :fill_color,
                  :visible

    def initialize(options = {})
      self.vertices = []
      self.color = "#000000"
      self.weight = 1
      self.opacity = 1
      self.visible = true
      options.each_pair { |key, value| send("#{key}=", value) }
      if !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set map for GoogleMap::Polyline."
      end
      if opacity > 1
        raise "Opacity cannot be greater than 100%"
      end
      if dom_id.blank?
        # This needs self to set the attr_accessor, why?
        self.dom_id = "#{map.dom_id}_polyline_#{map.overlays.size + 1}"
      end
    end
            
    def to_js

      js = []
      js << "#{dom_id}_vertices = new Array();"
      vertices.each_with_index do |point, index|
        js << "#{dom_id}_vertices[#{index}] = new GLatLng(#{point.lat}, #{point.lng});"
      end

      js << "var #{dom_id} = new GPolyline(#{dom_id}_vertices, '#{color}', #{weight}, #{opacity});"

      js.join "\n"
    end
    
    def to_static_param
      param = []
      
      param << "weight:#{weight}"
      
      param_color = color.delete("#")
      if param_color.to_i(16) > 0
        # Converts our percentage-given opacity into a hex value
        param_opacity = (opacity / (1/255.0)).to_i.to_s(16)
        param_color = "0x#{param_color}#{param_opacity.rjust(2,'0')}"
      end
      param << "color:#{param_color}"
      param << "fillcolor:0x#{fill_color.delete('#')}" if fill_color
      
      vertices.each do |point|
        param << point.to_static_param
      end
      
      return "path=" + param.join("|")
    end
  end
end