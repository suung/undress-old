require "hpricot"

module ::Hpricot #:nodoc:
  class Elem #:nodoc:
    def ancestors
      node, ancestors = parent, Elements[]
      while node.respond_to?(:parent) && node.parent
        ancestors << node
        node = node.parent
      end
      ancestors
    end
  end
end
