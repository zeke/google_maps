module GoogleMap
  
  class NumberedIcon < GoogleMap::Icon
    #include Reloadable

    alias_method :parent_initialize, :initialize

    def initialize(map, number=1)
      parent_initialize(:width => 26,
                        :height => 26,
                        :shadow_width => 0,
                        :shadow_height => 0,
                        :image_url => "http://zeke.sikelianos.com/projects/misc/google_maps_icons/#{number}.png",
                        :shadow_url => "http://labs.google.com/ridefinder/images/mm_20_shadow.png",
                        :anchor_x => 6,
                        :anchor_y => 20,
                        :info_anchor_x => 20,
                        :info_anchor_y => 5,
                        :map => map)
    end
  end

end