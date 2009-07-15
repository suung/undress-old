require File.expand_path(File.dirname(__FILE__) + "/textile")

module Undress
  class GreenCloth < Textile
    
    # table of contents
    pre_processing("ul.toc") do |toc|
      toc.swap "[[toc]]"
    end

    # headings
    rule_for(:h1) {|e| process_headings(e) }
    rule_for(:h2) {|e| process_headings(e) }
    rule_for(:h3) {|e| process_headings(e) }
    rule_for(:h4) {|e| process_headings(e) }
    rule_for(:h5) {|e| process_headings(e) }
    rule_for(:h6) {|e| process_headings(e) }

    # inline elements
    rule_for(:a) {|e|
      process_links_and_anchors(e)
    }
    
    # lists
    rule_for(:li) {|e|
      offset = ""
      li = e
      while li.parent
        if    li.parent.name == "ul" then offset = "*#{offset}"
        elsif li.parent.name == "ol" then offset = "##{offset}"
        else  return offset end
        li = li.parent.parent ? li.parent.parent : nil 
      end
      "\n#{offset} #{content_of(e)}"
    }

    # text formatting
    rule_for(:pre) {|e|
      if e.children.all? {|n| n.text? && n.content =~ /^\s+$/ || n.elem? && n.name == "code" }
        "\n\n<pre><code>#{content_of(e % "code")}</code></pre>"
      else
        "\n\n<pre>#{content_of(e)}</pre>"
      end
    }

    rule_for(:code) {|e|
      if e.inner_html.match(/\n/)
        if e.parent && e.parent.name != "pre"
          "<pre><code>#{content_of(e)}</code></pre>" 
        else
          "<code>#{content_of(e)}</code>"
        end
      else
        "@#{content_of(e)}@"
      end
    }

    # objects
    rule_for(:embed) {|e|
      e.to_html
    }

    rule_for(:object) {|e|
      e.to_html
    }
    
    rule_for(:param) {|e|
      e.to_html
    }

    def process_headings(h) 
      h.children.each {|e| 
        next if e.class == Hpricot::Text
        e.swap '<span></span>' if e.name != "a" || e.has_attribute?("href") && e["href"] !~ /^\/|(https?|s?ftp):\/\//
      }
      return "#{content_of(h)}\n#{'=' * h.inner_text.size}\n\n" if h.name == "h1"
      return "#{content_of(h)}\n#{'-' * h.inner_text.size}\n\n" if h.name == "h2"
      return "#{h.name}. #{content_of(h)}\n\n"
    end

    def process_links_and_anchors(e)
      return "" if e.empty?
      inner, name, href = e.inner_html, e.get_attribute("name"), e.get_attribute("href")

      # is an anchor? and cannot be child of any h1..h6
      if name && !e.parent.name.match(/^h1|2|3|4|5|6$/)
        fill_with = inner == name || inner == name.gsub(/-/,"\s") ? ["# ", "#{inner}", " #"] : ["# #{inner}", " -> ", "#{name} #"]
      # is a link to an anchor?
      elsif href && href =~ /^\/#/
        fill_with = ["\"#{inner}\"", ":", "#{href}"]
      elsif href && href =~ /^#/
        fill_with = ["#{inner}", " -> ", "#{href}"]
      # it is an external link?
      elsif href && href =~ /^(https?|s?ftp):\/\//
        fill_with = href.gsub(/^(https?|s?ftp):\/\//, "") == inner ? ["#{href}", "", ""] : ["#{inner}", " -> ", "#{href}"]
      # links starting without /
      elsif href && href =~ /^[^\/]/
        fill_with = ["", "#{e.inner_text}", ""]
      # link with 3 more /
      elsif href && href.count("/") >= 3
        fill_with = ["#{inner}", " -> ", "#{href}"]
      # wiki page with index
      elsif href && href =~ /(?:\/page\/\+)[0-9]+$/
        fill_with = ["#{inner}", " -> ", "+#{href.gsub(/\+[0-9]+$/)}"]
      # pages or group pages
      else
        context_name, page_name = href.split("/")[1..2]
        page_name = context_name if page_name.nil?
        wiki_page_name = page_name.gsub(/[a-z-]*[^\/]$/m) {|m| m.tr('-',' ')}

        # simple page
        if context_name == "page"
          return "[#{inner}]" if wiki_page_name == inner
          return "[#{inner} -> #{wiki_page_name}]"
        end
        # group page
        if context_name != page_name
          return "[#{context_name} / #{wiki_page_name}]" if wiki_page_name == inner
          return "[#{inner} -> #{wiki_page_name}]" if context_name == "page"
          return "[#{inner} -> #{context_name} / #{wiki_page_name}]"
        end 
        if inner == page_name || inner == wiki_page_name || inner == wiki_page_name.gsub(/\s/,"-")
          return "[#{wiki_page_name}]"
        end
        # fall back
        return "[#{inner} -> #{href}]"
      end
      "[%s%s%s]" % fill_with
    end
  end
  add_markup :greencloth, GreenCloth 
end
