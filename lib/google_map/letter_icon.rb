module GoogleMap

  class LetterIcon < GoogleMap::Icon
    #include Reloadable

    alias_method :parent_initialize, :initialize
    attr_accessor :label

    def initialize(letter)
      self.label = letter.to_s[0,1]
      parent_initialize(:map=>map, :image_url => "http://www.google.com/mapfiles/marker#{self.label}.png")
    end
    
    def to_static_param
      return "label:#{self.label.capitalize}"
    end
  end
end