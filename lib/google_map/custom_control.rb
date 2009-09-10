# To create a new custom control, you can follow the example from the ControlStreetViewOverlay class
# and the javascript example here:  http://code.google.com/apis/maps/documentation/controls.html#Custom_Controls
module GoogleMap
  class CustomControl
    # classes inheriting this class need to define the to_js method.
    attr_accessor :map,
                  :control_name,
                  :dom_id,
                  :text,
                  :icon,
                  :default_position,
                  :width,
                  :height
                  
    def initialize(options = {})
      self.default_position = "G_ANCHOR_TOP_RIGHT"
      self.width = 7
      self.height = 7
      
      options.each_pair { |key, value| send("#{key}=", value) }
      
      if map.blank? || !map.is_a?(GoogleMap::Map)
        raise "Must define a map for GoogleMap::StreetViewOverlayControl"
      end
    end
    
    # Child classes need to define this function
    def control_event_action_js
      js = []
      js << "  GEvent.addDomListener(#{dom_id}, 'click', function() {"
      js << "    alert('#{dom_id} clicked!');"
      js << "  });"
      js << ""
      return js.join("\n")
    end
    
    # Override this function if you want your own control style
    def control_style_js
      js = []
      js << "#{control_name}.prototype.setButtonStyle_ = function(button) {"
      js << "  button.style.textDecoration = 'underline';"
      js << "  button.style.color = '#0000cc';"
      js << "  button.style.backgroundColor = 'white';"
      js << "  button.style.font = 'small Arial';"
      js << "  button.style.border = '1px solid black';"
      js << "  button.style.padding = '2px';"
      js << "  button.style.marginBottom = '3px';"
      js << "  button.style.textAlign = 'center';"
      js << "  button.style.width = '6em';"
      js << "  button.style.cursor = 'pointer';"
      js << "}"
      return js.join("\n")
    end
    
    def initialize_js
      js = []
      
      js << "function #{control_name}() {}"
      js << ""
      
      js << "#{control_name}.prototype = new GControl();"
      
      js << "if( typeof container == 'undefined' ) {"
      js << "  var container;"
      js << "}"
      js << "#{control_name}.prototype.initialize = function(map) {"
      js << "  new_container = false;"
      js << "  if( !container ) {"
      js << "    container = document.createElement('div');"
      js << "    new_container = true;"
      js << "  }"
      js << "  var #{dom_id} = document.createElement('div');"
      js << ""
      
      js << "  this.setButtonStyle_(#{dom_id});"
      js << "  container.appendChild(#{dom_id});"
      
      if self.icon
        js << "  var icon = document.createElement('img');"
        js << "  icon.src = '#{icon}';"
        js << "  #{dom_id}.appendChild(icon);"
      else
        js << "  #{dom_id}.appendChild(document.createTextNode('#{text}'));"
      end
      
      js << ""
      
      js << control_event_action_js
      
      js << "  if(new_container) {"
      js << "    map.getContainer().appendChild(container);"
      js << "  }"
      js << "  return container;"
      js << "}"
      js << ""
      
      js << "#{control_name}.prototype.getDefaultPosition = function() {"
      js << "  return new GControlPosition(#{default_position}, new GSize(#{width}, #{height}));"
      js << "}"
      js << ""
      
      js << control_style_js
      
      return js.join("\n")
    end
    
    def add_control_to_map_js
      js = []
      
      js << "#{dom_id}_control = new #{control_name}();"
      js << "#{map.dom_id}.addControl(#{dom_id}_control);"
      
      return js.join("\n")
    end
    
    def remove_control_from_map_js
      js = []
      
      js << "#{map.dom_id}.removeControl(#{dom_id}_control);"
      
      return js.join("\n")
    end

    def add_listener_js
      return ""
    end
  end
end