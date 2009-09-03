module GoogleMap
  class StreetViewButtonControl < GoogleMap::CustomControl
    attr_accessor :lat,
                  :lng
    
    def initialize(options = {})
      self.control_name = "StreetViewControl"
      self.dom_id = "street_view_button"
      self.text = "Street View"
      super(options)
    end
    
    def control_event_action_js
      js = []
      js << "  GEvent.addDomListener(#{dom_id}, 'click', function() {"
      js << "    #{map.street_view.dom_id}_street_view_go(new GLatLng(#{lat}, #{lng}));"
      js << "  });"
      js << ""
      return js.join("\n")
    end
    
    def to_js
      js = []
      
      js << initialize_js
      
      return js.join("\n")
    end
  end
end