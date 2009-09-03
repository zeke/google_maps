module GoogleMap

  class StreetViewOverlay
    #include Reloadable
    #include UnbackedDomId

    attr_accessor :map,
                  :dom_id,
                  :visible

    def initialize(options = {})
      self.visible = true
      options.each_pair { |key, value| send("#{key}=", value) }
      if map.blank? || !map.is_a?(GoogleMap::Map)
        raise "map must be defined for GoogleMap::StreetViewOverlay"
      end
      
      if dom_id.blank?
        self.dom_id = "street_view_overlay"
      end
    end
            
    def to_js
      js = []
      js << "var #{self.dom_id} = new GStreetviewOverlay();"
      js.join "\n"
    end
  end
end