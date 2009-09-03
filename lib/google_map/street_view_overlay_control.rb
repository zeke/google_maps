module GoogleMap
  class StreetViewOverlayControl < GoogleMap::CustomControl
    
    def initialize(options = {})
      self.control_name = "StreetViewOverlayControl"
      self.dom_id = "street_view_overlay_button"
      self.text = "SV Display"
      super(options)
    end
    
    def control_event_action_js
      js = []
      js << "  GEvent.addDomListener(#{dom_id}, 'click', function() {"
      js << "    if( !street_view_overlay_added ) {"
      js << "      #{map.dom_id}.addOverlay(street_view_overlay);"
      js << "    }else {"
      js << "      #{map.dom_id}.removeOverlay(street_view_overlay);"
      js << "    }"
      js << "  });"
      js << ""
      return js.join("\n")
    end
    
    def initialize_js
      js = []
      js << "var street_view_overlay_added = false;"
      js << super
      
      
      return js.join("\n")
    end
    
    def to_js
      js = []
      
      js << initialize_js
      
      return js.join("\n")
    end
    
    def add_listener_js
      js = []
      
      js << "  GEvent.addDomListener(#{map.dom_id}, 'addoverlay', function(overlay) {"
      js << "    if(overlay == street_view_overlay) {"
      js << "      street_view_overlay_added = true;"
      js << "    }"
      js << "  });"
      js << ""
      
      js << "  GEvent.addDomListener(#{map.dom_id}, 'removeoverlay', function(overlay) {"
      js << "    if(overlay == street_view_overlay) {"
      js << "      street_view_overlay_added = false;"
      js << "    }"
      js << "  });"
      
      return js.join("\n")
    end
  end
end