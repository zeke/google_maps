module GoogleMap

  class StreetViewOverlay
    #include Reloadable
    #include UnbackedDomId

    attr_accessor :dom_id

    def initialize(options = {})
      options.each_pair { |key, value| send("#{key}=", value) }
      if dom_id.blank?
        self.dom_id = "streetview_overlay"
      end
    end
            
    def to_js
      js = []
      js << "#{self.dom_id} = new GStreetviewOverlay();"
      js.join "\n"
    end
  end
end