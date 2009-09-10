module GoogleMap

  class Marker

    include ActionView::Helpers::JavaScriptHelper

    attr_accessor :dom_id,
                  :lat,
                  :lng,
                  :html,
                  :marker_icon_path,
                  :marker_hover_text,
                  :map,
                  :icon, # For static images this must be a LetterIcon instance initialized with an
                         # alphanumeric value {A-Z, 0-9}
                  :open_infoWindow,
                  :draggable,
                  :dragstart,
                  :dragend,
                  :size, # must be one of 'tiny', 'mid', or 'small'
                  :color, # 0xFFFFCC format, or one of:
                          # black, brown, green, purple, yellow, blue, gray, orange, red, white
                          # transparency not supported for markers
                  :click_street_view

    def initialize(options = {})
      self.click_street_view = false
      options.each_pair { |key, value| send("#{key}=", value) }
      
      if lat.blank? or lng.blank? or !map or !map.kind_of?(GoogleMap::Map)
        raise "Must set lat, lng, and map for GoogleMapMarker."
      end
      
      if dom_id.blank?
        # This needs self to set the attr_accessor, why?
        self.dom_id = "#{map.dom_id}_marker_#{map.markers.size + 1}"
      end
      
    end

    def open_info_window_function
      js = []

      js << "function #{dom_id}_infowindow_function() {"
      js << "  var windowOptions = {"
      js << "    onOpenFn:function(){"
      js << "      markerClicked = true;"
      js << "    },"
      js << "    onCloseFn:function(){"
      js << "      setTimeout('markerClicked = false;', 100);"
      js << "    }"
      js << "  };"
      js << "  #{map.dom_id}.openInfoWindowHtml(new GLatLng( #{lat}, #{lng} ), \"#{escape_javascript(html)}\", windowOptions);" if self.html
      js << "  if(!markerClicked) {"
      js << "    markerClicked = true;"
      # Without this boolean toggle, the map will register two clicks:
      # one for the marker, and one on the map.  This prevents the
      # incorrect location being set
      js << "    setTimeout('markerClicked = false;', 100);" if !self.html
      js << "  }"
      
      if self.map.street_view && self.click_street_view
        js << "  my_loc = new GLatLng( #{lat}, #{lng} );"
        js << "  #{self.map.street_view.dom_id}_street_view_go_with_POV(my_loc);"
      end
      
      js << "}"

      return js.join("\n")
    end

    def open_info_window
      "#{dom_id}_infowindow_function();"
    end

    def to_js
      js = []

      h = ", title: '#{escape_javascript(marker_hover_text)}'" if marker_hover_text

      # If a icon is specified, use it in marker creation.
      i = ", { icon: #{icon.dom_id} #{h} }" if icon
      i = ", { icon: new GIcon( G_DEFAULT_ICON, '#{marker_icon_path}') #{h} }" if marker_icon_path
		
      options = ', { draggable: true }' if self.draggable
      js << "#{dom_id} = new GMarker( new GLatLng( #{lat}, #{lng} ) #{i} #{options} );"
      js << "GEvent.bind(#{dom_id}, \"dragstart\", #{dom_id}, #{self.dragstart});" if dragstart
      js << "GEvent.bind(#{dom_id}, \"dragend\", #{dom_id}, #{self.dragend});" if dragend
      
      if self.html
        js << "GEvent.addListener(#{dom_id}, 'click', function() {#{dom_id}_infowindow_function()});"
      end

      js << "#{map.dom_id}.addOverlay(#{dom_id});"

      if open_infoWindow
        js << "GEvent.trigger(#{dom_id}, 'click')"
      end

      return js.join("\n")
    end
    
    def to_static_param
      param = []
      
      param << "size:#{size}" if self.size
      param << "color:#{color}" if self.color
      param << self.icon.to_static_param if self.icon.instance_of?(LetterIcon)
      param << "#{lat},#{lng}"
      return "markers=" + param.join("|")
    end

  end

end