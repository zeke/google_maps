module GoogleMap
  class StreetView
    #include Reloadable
    #include UnbackedDomId
    attr_accessor :dom_id,
                  :map,
                  :lat,
                  :lng,
                  :yaw,
                  :pitch,
                  :zoom

    def initialize(options = {})
      options.each_pair { |key, value| send("#{key}=", value) }
      
      if !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set map for GoogleMap:StreetView."
      end
      
      if self.dom_id.blank?
        self.dom_id = "#{self.map.dom_id}_street_view"
      end
    end

    #def to_html
    #  html = []
    #  html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"
    #  html << "<script type=\"text/javascript\">"
    #  html << to_js
    #  html << "</script> "

    #  return html.join("\n")
    #end

    def to_js
      js = []
      js << "var #{dom_id}_street_view;"
      js << "var #{dom_id}_street_view_client;"
      js << "function initialize_google_street_view_#{dom_id}() {"
      #pOpts = []
      
      #if self.lat && self.lng
      #  js << "  var my_loc = new GLatLng(#{lat}, #{lng});"
      #  pOpts << "latlng:my_loc"
      #end

      #if view_js = pov_js
      #  js << "  my_pov = #{view_js};"
      #  pOpts << "pov:my_pov"
      #end
      
      js << "  #{dom_id}_street_view_client = new GStreetviewClient();"
      #js << "  panorama_options = {#{pOpts.join(', ')}};"
      js << "  #{dom_id}_street_view = new GStreetviewPanorama(document.getElementById(\"#{dom_id}\"));"
      
      setLocJs = ""
      view_js = pov_js
      if self.lat && self.lng
        setLocJs << "  #{dom_id}_street_view.setLocationAndPOV(new GLatLng(#{lat}, #{lng})"
        if view_js
          setLocJs << ", #{view_js});"
        else
          setLocJs << ");"
        end
      elsif view_js
        setLocJs << "  #{dom_id}_street_view.setPOV(#{view_js});"
      end
      js << setLocJs
      
      #js << "  #{dom_id}_street_view.hide();"
      js << "  GEvent.addListener(#{dom_id}_street_view, \"error\", handle_no_flash);"
      js << "}"
      js << ""
      
      js << "function handle_no_flash(errorCode) {"
      js << "  if(errorCode == 603) {"
      js << "    document.getElementById(\"#{dom_id}\").innerHtml = 'The flash player is required for street view.  You may download it from the <a href=\"http://get.adobe.com/flashplayer/\">Adobe website</a>.';"
      js << "  }"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_street_view_map_click(overlay,latlng) {"
      js << "  if( !markerClicked ) {"
      js << "    #{self.map.street_view.dom_id}_street_view_go(latlng);"
      js << "  }"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_street_view_go(latlng) {"
      js << "  #{dom_id}_street_view_client.getNearestPanorama(latlng, #{dom_id}_street_view_show_loc);"
      #js << "  #{dom_id}_street_view.setLocationAndPOV(latlng, my_pov);"
      #js << "  #{dom_id}_street_view.show();"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_street_view_show_loc(panoData) {"
      js << "  if( panoData.code != 200 ){"
      js << "    return;"
      js << "  }"
      js << ""
      
      js << "  #{dom_id}_street_view.setLocationAndPOV(panoData.location.latlng);"
      #js << "  #{dom_id}_street_view.show();"
      js << "}"

      # Load the map on window load preserving anything already on window.onload.
      #js << "if (typeof window.onload != 'function') {"
      #js << "  window.onload = initialize_google_street_view_#{dom_id};"
      #js << "} else {"
      #js << "  old_before_google_street_view_#{dom_id} = window.onload;"
      #js << "  window.onload = function() {"
      #js << "    old_before_google_street_view_#{dom_id}();"
      #js << "    initialize_google_street_view_#{dom_id}();"
      #js << "  }"
      #js << "}"

      return js.join("\n")
    end
    
    def event_listener
      js = []
      
      js << "GEvent.addListener(#{map.dom_id}, \"click\", #{dom_id}_street_view_map_click);"
      return js.join("\n")
    end
    
    def pov_js
      js = nil
      
      if self.yaw || self.pitch || self.zoom
        js = "{"
        js << "yaw:#{self.yaw}" if self.yaw
        js << "pitch:#{self.pitch}" if self.pitch
        js << "zoom:#{self.zoom}" if self.zoom
        js << "}"
      end
      
      return js
    end

    def div(width = '100%', height = '100%')
      "<div onload=\"initialize()\" onunload=\"GUnload()\" id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
    end
  end
end