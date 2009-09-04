module GoogleMap
  class StreetViewButtonControl < GoogleMap::CustomControl
    attr_accessor :lat,
                  :lng,
                  :face_point
    
    def initialize(options = {})
      self.face_point = false
      self.control_name = "StreetViewControl"
      self.dom_id = "street_view_button"
      self.text = "Street View"
      super(options)
    end
    
    def control_event_action_js
      js = []
      js << "  GEvent.addDomListener(#{dom_id}, 'click', function() {"
      
      if self.face_point
        js << "    my_loc = new GLatLng(#{lat}, #{lng});"
        js << "    #{map.street_view.dom_id}_street_view_go_with_POV(my_loc);"
      else
        js << "    #{map.street_view.dom_id}_street_view_go(new GLatLng(#{lat}, #{lng}));"
      end
      
      js << "  });"
      js << ""
      return js.join("\n")
    end
    
    def add_control_to_map_js
      js = []
      
      js << "#{dom_id}_street_exists_client = new GStreetviewClient();"
      js << "#{dom_id}_street_exists_client.getNearestPanorama(new GLatLng(#{lat}, #{lng}), function(panoData) {"
      js << "  if( panoData.code != 200) {"
      js << "    return;"
      js << "  }else{"
      js << super()
      js << "  }"
      js << "});"
      
      return js.join("\n")
    end
    
    def to_js
      js = []
      
      js << initialize_js
      
      return js.join("\n")
    end
  end
end