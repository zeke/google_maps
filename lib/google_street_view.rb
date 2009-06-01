class GoogleStreetView
  #include Reloadable
  #include UnbackedDomId
  attr_accessor :dom_id,
                :lat,
                :lng

  def initialize(options = {})
    self.dom_id = 'google_street_view'
    options.each_pair { |key, value| send("#{key}=", value) }
  end

  def to_html
    html = []
    html << "<script src='http://maps.google.com/maps?file=api&amp;v=2&amp;key=#{GOOGLE_APPLICATION_ID}' type='text/javascript'></script>"
    html << "<script type=\"text/javascript\">"
    html << to_js
    html << "</script> "

    return html.join("\n")
  end

  def to_js
    js = []
    js << "var #{dom_id}"
    js << "function initialize_google_street_view_#{dom_id}() {"
    js << "  var my_loc = new GLatLng(#{lat},#{lng});"
    js << "  panoramaOptions = { latlng:my_loc };"
    js << "  #{dom_id} = new GStreetviewPanorama(document.getElementById(\"#{dom_id}\"), panoramaOptions);"
    js << "}"

    # Load the map on window load preserving anything already on window.onload.
    js << "if (typeof window.onload != 'function') {"
    js << "  window.onload = initialize_google_street_view_#{dom_id};"
    js << "} else {"
    js << "  old_before_google_street_view_#{dom_id} = window.onload;"
    js << "  window.onload = function() {"
    js << "    old_before_google_street_view_#{dom_id}();"
    js << "    initialize_google_street_view_#{dom_id}();"
    js << "  }"
    js << "}"

    return js.join("\n")
  end

  def div(width = '100%', height = '100%')
    "<div onload=\"initialize()\" onunload=\"GUnload()\" id='#{dom_id}' style='width: #{width}; height: #{height}'></div>"
  end
end
