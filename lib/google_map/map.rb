module GoogleMap
  class Map
    include UnbackedDomId
    attr_accessor :dom_id,
      :markers,
      :overlays,
      :controls,
      :inject_on_load,
      :zoom,
      :center,
      :double_click_zoom,
      :continuous_zoom,
      :scroll_wheel_zoom,
      :bounds,
      :map_type,
      :ssl,
      :street_view
      
    STATIC_MAP_TYPES = {
      'G_NORMAL_MAP' => 'roadmap',
      'G_SATELLITE_MAP' => 'satellite',
      'G_HYBRID_MAP' => 'hybrid',
      'G_PHYSICAL_MAP' => 'terrain'
    }

    def initialize(options = {})
      self.dom_id = 'google_map'
      self.markers = []
      self.overlays = []
      self.bounds = []
      self.controls = [ :large, :scale, :type ]
      self.double_click_zoom = true
      self.continuous_zoom = false
      self.scroll_wheel_zoom = false
      self.ssl = false
      options.each_pair { |key, value| send("#{key}=", value) }
    end
    
    def static_img(width = 400, height = 400, options = {})
      url = []
      
      if( self.ssl )
        url << "https://maps-api-ssl.google.com/maps/api/staticmap?sensor=false&client=#{GOOGLE_CLIENT_ID}"
      else
        url << "http://maps.google.com/maps/api/staticmap?sensor=false&key=#{GOOGLE_APPLICATION_ID}"
      end
      url << "zoom=#{self.zoom}" if self.zoom
      url << "size=#{width}x#{height}"
      url << "center=#{center.to_static_param}" if self.center
      self.markers.each do |marker|
        url << marker.to_static_param
      end
      self.overlays.each do |overlay|
        url << overlay.to_static_param if overlay.is_a? GoogleMap::Polyline
      end
      
      if STATIC_MAP_TYPES.include?(self.map_type)
        options[:maptype] ||= STATIC_MAP_TYPES[self.map_type]
      elsif STATIC_MAP_TYPES.has_value?(self.map_type)
        options[:maptype] ||= self.map_type
      else
        options[:maptype] ||= 'roadmap'
      end
      options[:format] ||= 'png'
      options.each_pair { |key, value| url << "#{key}=#{value}"}
      return url.join("&")
    end

    def to_html
      html = []

      if( self.ssl )
        html << "<script src='https://maps-api-ssl.google.com/maps?file=api&v=2&client=#{GOOGLE_CLIENT_ID}&sensor=false' type='text/javascript'></script>"
      else
        html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"
      end
      html << "<script type=\"text/javascript\">\n/* <![CDATA[ */\n"  
      html << to_js
      html << "/* ]]> */</script> "

      return html.join("\n")
    end

    def to_enable_prefix true_or_false
      true_or_false ? "enable" : "disable"
    end

    def to_js
      js = []

      # Initialise the map variable so that it can externally accessed.
      js << "var #{dom_id};"
      js << "var markerClicked = false;"
      markers.each { |marker| js << "var #{marker.dom_id};" }
      

      js << street_view_js
      js << center_map_js
      js << markers_functions_js
      js << custom_controls_js
      
      overlays.each do |overlay|
        js << overlay.to_js
      end

      js << "function initialize_google_map_#{dom_id}() {"
      js << "  if(GBrowserIsCompatible()) {"
      js << "    #{dom_id} = new GMap2(document.getElementById('#{dom_id}'));"

      js << "    if (self['GoogleMapOnLoad']) {"
      js << "      #{dom_id}.load = GEvent.addListener(#{dom_id},'load',GoogleMapOnLoad);"
      js << "    }"
      
      js << "    initialize_google_street_view_#{street_view.dom_id}();" if self.street_view

      js << '    ' + map_type_js
      js << '    ' + center_on_bounds_js
      js << '    ' + markers_icons_js
      js << '    ' + controls_js

      # Put all the markers on the map.
      for marker in markers
        js << '    ' + marker.to_js
        js << ''
      end

      overlays.each do |overlay|
        if overlay.visible
          js << "#{dom_id}.addOverlay(#{overlay.dom_id});"
        end
      end

      js << "#{dom_id}.#{to_enable_prefix double_click_zoom}DoubleClickZoom();"
      js << "#{dom_id}.#{to_enable_prefix continuous_zoom}ContinuousZoom();"
      js << "#{dom_id}.#{to_enable_prefix scroll_wheel_zoom}ScrollWheelZoom();"

      js << '    ' + inject_on_load.gsub("\n", "    \n") if inject_on_load
      js << "  }"
      js << "}"

      # Load the map on window load preserving anything already on window.onload.
      js << "if (typeof window.onload != 'function') {"
      js << "  window.onload = initialize_google_map_#{dom_id};"
      js << "} else {"
      js << "  old_before_google_map_#{dom_id} = window.onload;"
      # In my testing the following doesn't actually appear to work...?
      js << "  window.onload = function() {" 
      js << "    old_before_google_map_#{dom_id}();"
      js << "    initialize_google_map_#{dom_id}();"
      js << "  }"
      js << "}"

      # Unload the map on window unload preserving anything already on window.onunload.
      #js << "if (typeof window.onunload != 'function') {"
      #js << "  window.onunload = GUnload();"
      #js << "} else {"
      #js << "  old_before_onunload = window.onload;"
      #js << "  window.onunload = function() {" 
      #js << "    old_before_onunload();"
      #js << "    GUnload();" 
      #js << "  }"
      #js << "}"

      return js.join("\n")
    end

    def map_type_js
      js = []
      if map_type
        js << "#{dom_id}.setMapType(#{map_type});"
      end    
      js.join("\n")
    end

    def controls_js
      js = []

      controls.each do |control|
        c = nil
        case control
        when :large, :small, :overview
          c = "G#{control.to_s.capitalize}MapControl"
        when :large_3d
          c = "GLargeMapControl3D"
        when :scale
          c = "GScaleControl"
        when :type
          c = "GMapTypeControl"
        when :menu_type
          c = "GMenuMapTypeControl"
        when :hierachical_type
          c = "GHierarchicalMapTypeControl"
        when :zoom
          c = "GSmallZoomControl"
        when :zoom_3d
          c = "GSmallZoomControl3D"
        when :nav_label
          c = "GNavLabelControl"
        when :street_view
          js << street_view.event_listener
        else
          if control.is_a?(GoogleMap::CustomControl)
            js << control.add_control_to_map_js
            js << control.add_listener_js
          else
            raise "Unknown control type:  #{control}"
          end
        end
        
        js << "#{dom_id}.addControl(new #{c}());" if c
      end

      return js.join("\n")
    end
    
    def custom_controls_js
      js = []
      
     controls.each do |control|
        if control.is_a?(GoogleMap::CustomControl)
          js << control.to_js
        end
      end
      
      return js.join("\n")
    end
    
    def street_view_js
      js = []
      if controls.include? :street_view
        if !self.street_view || !self.street_view.is_a?(GoogleMap::StreetView)
          self.street_view = GoogleMap::StreetView.new(
            :map => self
          )
        end
      end
      if self.street_view
        js << street_view.to_js
      end
    end

    def markers_functions_js
      js = []
      for marker in markers
        js << marker.open_info_window_function
      end
      return js.join("\n")
    end

    def markers_icons_js
      icons = []
      for marker in markers
        if marker.icon and !icons.include?(marker.icon)
          icons << marker.icon 
        end
      end
      js = []
      for icon in icons
        js << icon.to_js
      end
      return js.join("\n")
    end

    # Creates a JS function that centers the map on the specified center
    # location if given to the initialisers, or on the maps markers if they exist, or
    # at (0,0) if not.
    def center_map_js
      if self.zoom
        zoom_js = zoom
      else
        zoom_js = "#{dom_id}.getBoundsZoomLevel(#{dom_id}_latlng_bounds)"
      end
      set_center_js = []
      
      if self.center
        # Also set a 'default' lat/lng on the street view if available, as our center point
        if self.street_view
          self.street_view.lat = center.lat if !self.street_view.lat
          self.street_view.lng = center.lng if !self.street_view.lng
        end
        set_center_js << "#{dom_id}.setCenter(new GLatLng(#{center.lat}, #{center.lng}), #{zoom_js});"
      else
        synch_bounds
        set_center_js << "var #{dom_id}_latlng_bounds = new GLatLngBounds();"
        
        bounds.each do |point|
          set_center_js << "#{dom_id}_latlng_bounds.extend(new GLatLng(#{point.lat}, #{point.lng}));"
        end  
        
        set_center_js << "#{dom_id}.setCenter(#{dom_id}_latlng_bounds.getCenter(), #{zoom_js});"
      end
      
      "function center_#{dom_id}() {\n  #{check_resize_js}\n  #{set_center_js.join "\n"}\n}"
    end

    def synch_bounds
      
      overlays.each do |overlay|
        if overlay.is_a? GoogleMap::Polyline
          overlay.vertices.each do |v|
            bounds << v #i do not like this inconsistent interface
          end 
        end
      end
      
      markers.each do |m|
        bounds << m
      end    
      
      bounds.uniq!
    end

    def check_resize_js
      return "#{dom_id}.checkResize();"
    end

    def center_on_bounds_js
      return "center_#{dom_id}();"
    end

    def div(width = '100%', height = '100%')
      "<div id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
    end
    
    def noflash_div(width = '100%')
      "<div id='#{dom_id}_no_flash' style='width: #{width}'></div>"
    end

  end
end
