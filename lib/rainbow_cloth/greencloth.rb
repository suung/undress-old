module RainbowCloth
  class Document
    def to_greencloth
      GreenCloth.process!(doc)
    end
  end

  class GreenCloth < Textile
  end
end
