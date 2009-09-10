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
                  :zoom,
                  :close_control

    def initialize(options = {})
      self.close_control = false
      options.each_pair { |key, value| send("#{key}=", value) }
      
      if !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set map for GoogleMap:StreetView."
      end
      
      if self.dom_id.blank?
        self.dom_id = "#{self.map.dom_id}_street_view"
      end
    end

    def to_js
      js = []
      js << "var #{dom_id}_street_view;"
      js << "var #{dom_id}_street_view_client;"
      js << "var my_loc;"
      js << "var user_has_flash = true;"
      js << "function initialize_google_street_view_#{dom_id}() {"
      
      js << "  #{dom_id}_street_view_client = new GStreetviewClient();"
      js << "  #{dom_id}_street_view = new GStreetviewPanorama(document.getElementById(\"#{dom_id}\"));"
      js << "  GEvent.addListener(#{dom_id}_street_view, \"error\", handle_no_flash);"
      
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
      
      js << "}"
      js << ""
      
      #js << turn_off_street_view_function_js
      js << "function handle_no_flash(errorCode) {"
      js << "  if(errorCode == 603) {"
      #js << "    user_has_flash = false;"
      #js << "    turn_off_street_view();"
      #js << "    alert('no flash!');"
      js << "    user_has_flash = false;"
      js << hide_controls_js
      js << "    document.getElementById(\"#{self.map.dom_id}_no_flash\").innerHTML = 'Flash player is required for street view.  You may download it from the <a href=\"http://get.adobe.com/flashplayer/\" target=\"_blank\">Adobe website</a>.';"
      js << "    return false;"
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
      js << "}"
      js << ""
      
      js << "function #{dom_id}_street_view_go_with_POV(latlng) {"
      js << "  #{dom_id}_street_view_client.getNearestPanorama(latlng, #{dom_id}_street_view_show_loc_and_POV)"
      js << "}"
      js << ""
      
      js << create_control_functions_js
      
      js << "function #{dom_id}_street_view_show_loc(panoData) {"
      js << "  if( panoData.code != 200 ){"
      js << "    return;"
      js << "  }"
      js << ""
      
      js << "  #{dom_id}_street_view.setLocationAndPOV(panoData.location.latlng);"
      js << "  if(user_has_flash){"
      js << show_controls_js
      js << "  }"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_street_view_show_loc_and_POV(panoData) {"
      js << "  if( panoData.code != 200 ){"
      js << "    return;"
      js << "  }"
      js << ""
      
      js << "  var angle = #{dom_id}_compute_angle(my_loc, panoData.location.latlng);"
      js << "  #{dom_id}_street_view.setLocationAndPOV(panoData.location.latlng, {yaw: angle});"
      js << "  if(user_has_flash){"
      js << show_controls_js
      js << "  }"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_compute_angle(endLatLng, startLatLng) {"
      js << "  var DEGREE_PER_RADIAN = 57.2957795;"
      js << "  var RADIAN_PER_DEGREE = 0.017453;"
      js << "  var dlat = endLatLng.lat() - startLatLng.lat();"
      js << "  var dlng = endLatLng.lng() - startLatLng.lng();"
      js << "  var yaw = Math.atan2(dlng * Math.cos(endLatLng.lat() * RADIAN_PER_DEGREE), dlat) * DEGREE_PER_RADIAN;"
      js << "  return #{dom_id}_wrap_angle(yaw);"
      js << "}"
      js << ""
      
      js << "function #{dom_id}_wrap_angle(angle){"
      js << "  if( angle >= 360) {"
      js << "    angle -= 360;"
      js << "  }else if( angle < 0) {"
      js << "    angle += 360;"
      js << "  }"
      js << "  return angle;"
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
    
    #def turn_off_street_view_function_js
    #  js = []
    #  
    #  js << "function turn_off_street_view(){"
    #  self.map.controls.each do |control|
    #    if control.is_a?(StreetViewButtonControl)
    #      js << control.remove_control_from_map_js
    #    end
    #  end
    #  js << "}"
    #  
    #  return js.join("\n")
    #end
    
    def create_control_functions_js
      js = []
      
      if self.close_control
        js << "var #{dom_id}_close_control"
        js << "function create_#{dom_id}_street_view_close_control() {"
        js << "  #{dom_id}_close_control = document.createElement('div');"
        js << "  document.getElementById('#{dom_id}').appendChild(#{dom_id}_close_control);"
        js << "  #{dom_id}_close_control.appendChild(document.createTextNode('Map'));"
        js << "  #{dom_id}_close_control.onclick = function(){"
        js << "    #{dom_id}_street_view.hide();"
        js << hide_controls_js
        js << "  }"
        js << "  #{dom_id}_close_control.style.textDecoration = 'underline';"
        js << "  #{dom_id}_close_control.style.color = '#0000cc';"
        js << "  #{dom_id}_close_control.style.backgroundColor = 'white';"
        js << "  #{dom_id}_close_control.style.zIndex = '2';"
        js << "  document.getElementById('#{dom_id}').style.zIndex = '1';"
        js << "  #{dom_id}_close_control.style.position = 'absolute';"
        js << "  #{dom_id}_close_control.style.right = '10px';"
        js << "  #{dom_id}_close_control.style.padding = '2px';"
        js << "  #{dom_id}_close_control.style.borderStyle = 'solid';"
        js << "  #{dom_id}_close_control.style.borderWidth = '1px';"
        js << "  #{dom_id}_close_control.style.top = '8px';"
        js << "  #{dom_id}_close_control.style.cursor = 'pointer';"
        js << "}"
        
        js << "function hide_#{dom_id}_street_view_close_control() {"
        js << "  #{dom_id}_close_control.style.visibility = 'hidden';"
        js << "}"
        
        js << "function show_#{dom_id}_street_view_close_control() {"
        js << "  #{dom_id}_close_control.style.visibility = 'visible';"
        js << "}"
      end
      
      return js.join("\n")
    end
    
    def show_controls_js
      js = []
      
      if self.close_control
        js << "  if(#{dom_id}_close_control){"
        js << "    show_#{dom_id}_street_view_close_control();"
        js << "  }else {"
        js << "    create_#{dom_id}_street_view_close_control();"
        js << "  }"
      end
      
      return js.join("\n")
    end
    
    def hide_controls_js
      js = []
      
      if self.close_control
        js << "  hide_#{dom_id}_street_view_close_control();"
      end
      
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