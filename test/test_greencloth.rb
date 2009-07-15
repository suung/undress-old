require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class RainbowCloth::GreenClothTest < Test::Unit::TestCase
  def assert_renders_greencloth(greencloth, html)
    assert_equal greencloth, RainbowCloth.new(html, :xhtml_strict => true).to_greencloth
  end

  # outline
  context "outline" do
    test "table of contents toc" do
      html = "<ul class='toc'><li class='toc1'><a href='#fruits'><span>1</span> Fruits</a></li><ul><li class='toc2'><a href='#tasty-apples'><span>1.1</span> Tasty Apples</a></li><ul><li class='toc3'><a href='green'><span>1.1.1</span> Green</a></li><li class='toc3'><a href='#red'><span>1.1.2</span> Red</a></li></ul>"
      greencloth = "[[toc]]"
      assert_renders_greencloth greencloth, html 
    end
  end

  # basics
  context "basics" do
    test "headers" do
      html = "<h1 class='first'>header one</h1>\n<h2>header two</h2>"
      greencloth = "header one\n==========\n\nheader two\n----------\n"
      assert_renders_greencloth greencloth, html 
    end

    test "headers with paragraph" do
      html = "<p>la la la</p>\n<h1 class='first'>header one</h1>\n<h2>header two</h2>\n<p>la la la</p>"
      greencloth = "la la la\n\nheader one\n==========\n\nheader two\n----------\n\nla la la\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # sections
  # allways we render h1 with ==== and h2 with ----
  context "Convert sections" do
    test "one section no heading" do 
      html = "<div class='wiki_section' id='wiki_section-0'><p>start unheaded section</p><p>line line line</p></div>"
      greencloth = "start unheaded section\n\nline line line\n"
      assert_renders_greencloth greencloth, html 
    end

    test "one section with heading" do
      html = "<div class='wiki_section' id='wiki_section-0'><h2 class='first'>are you ready?!!?</h2><p>here we go now!</p></div>"
      greencloth = "are you ready?!!?\n-----------------\n\nhere we go now!\n"
      assert_renders_greencloth greencloth, html 
    end

    test "all headings" do
      html = "<h1>First</h1><h2>Second</h2><h3>Tres</h3><h4>Cuatro</h4><h5>Five</h5><h6>Six</h6>"
      greencloth = "First\n=====\n\nSecond\n------\n\nh3. Tres\n\nh4. Cuatro\n\nh5. Five\n\nh6. Six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "multiple sections with text" do
      html = "<div class='wiki_section' id='wiki_section-0'><h2 class='first'>Section One</h2><p>section one line one is here<br />section one line two is next</p><p>Here is section one still</p></div><div class='wiki_section' id='wiki_section-1'><h1>Section Two</h1><p>Section two first line<br />Section two another line</p></div><div class='wiki_section' id='wiki_section-2'><h2>Section 3 with h2</h2><p>One more line for section 3</p></div><div class='wiki_section' id='wiki_section-3'><h3>final section 4</h3><p>section 4 first non-blank line</p>\n</div>"
      greencloth = "Section One\n-----------\n\nsection one line one is here\nsection one line two is next\n\nHere is section one still\n\nSection Two\n===========\n\nSection two first line\nSection two another line\n\nSection 3 with h2\n-----------------\n\nOne more line for section 3\n\nh3. final section 4\n\nsection 4 first non-blank line\n"
      assert_renders_greencloth greencloth, html 
    end
  end

  # lists
  # TODO: start attribute not implemented
  context "Converting html lists to greencloth" do
    test "hard break in list" do
      html = "<ul>\n\t<li>first line</li>\n\t<li>second<br />\n\tline</li>\n\t<li>third line</li>\n</ul>\n"
      greencloth = "* first line\n* second\nline\n* third line\n" 
      assert_renders_greencloth greencloth, html 
    end

    test "mixed nesting" do
      html = "<ul><li>bullet\n<ol>\n<li>number</li>\n<li>number\n<ul>\n\t<li>bullet</li>\n</ul></li>\n<li>number</li>\n<li>number with<br />a break</li>\n</ol></li>\n<li>bullet\n<ul><li>okay</li></ul></li></ul>"
      greencloth = "* bullet\n*# number\n*# number\n*#* bullet\n*# number\n*# number with\na break\n* bullet\n** okay\n"
      assert_renders_greencloth greencloth, html 
    end

    test "list continuation" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\n# one\n# two\n# three\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue after break" do # uses start
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol><li>one</li><li>two</li><li>three</li></ol><p>test</p><ol start='4'><li>four</li><li>five</li><li>six</li></ol>"
      greencloth = "# one\n# two\n# three\n\ntest\n\n# one\n# two\n# three\n\ntest\n\n# four\n# five\n# six\n"
      assert_renders_greencloth greencloth, html 
    end

    test "continue list when prior list contained nested list" do # uses start
      greencloth = "# one\n# two\n# three\n\n# four\n# five\n## sub-note\n## another sub-note\n# six\n\n# seven\n# eight\n# nine\n"
      html = "<ol><li>one</li><li>two</li><li>three</li></ol><ol start='4'><li>four</li><li>five<ol><li>sub-note</li><li>another sub-note</li></ol></li><li>six</li></ol><ol start='7'><li>seven</li><li>eight</li><li>nine</li></ol>"
      assert_renders_greencloth greencloth, html 
    end

    test "" do

    end
  end

  # links
  context "Converting html links to greencloth" do
    test "convert a link to a wiki page inside a paragraph" do
      html = "<p>this is a <a href='/page/plain-link'>plain link</a> in some text</p>"
      greencloth = "this is a [plain link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace" do
      html= "<p>this is a <a href='/namespaced/link'>link</a> in some text</p>"
      greencloth = "this is a [namespaced / link] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to a wiki page" do
      html= "<p>this is a <a href='/page/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end

    test "convert a link to a wiki page with namespace and text different than link dest" do
      html= "<p>this is a <a href='/namespace/something-else'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> namespace / something else] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an absolute path" do
      html = "<p>this is a <a href='/an/absolute/path'>link to</a> in some text</p>"
      greencloth = "this is a [link to -> /an/absolute/path] in some text\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "convert a link to an external domain" do
      html = "<p>this is a <a href='https://riseup.net'>link to</a> a url</p>"
      greencloth = "this is a [link to -> https://riseup.net] a url\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to an external domain with the same text as dest" do
      html = "<p>url in brackets <a href='https://riseup.net/'>riseup.net</a></p>"
      greencloth = "url in brackets [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link to a wiki page with the same name as dest" do
      html = "<p>a <a href='/page/name-link'>name link</a> in need of humanizing</p>"
      greencloth = "a [name link] in need of humanizing\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link to a user blue" do
      html = "<p>link to a user <a href='/blue'>blue</a></p>"
      greencloth = "link to a user [blue]\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "link with dashes should keep the dashes" do
      html = "<p><a href='/-dashes/in/the/link-'>link to</a></p>"
      greencloth = "[link to -> /-dashes/in/the/link-]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "link with underscores should keep the underscores" do
      html = "<p>links <a href='/page/with_underscores'>with_underscores</a> should keep underscore</p>"
      greencloth = "links [with_underscores] should keep underscore\n"
      assert_renders_greencloth greencloth, html 
    end
    
    test "a link inside a li element" do
      html ="<ul>\n<li>\n\t\t\n<a href='/page/this'>link to</a></li></ul>"
      greencloth = "* [link to -> this]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "an external link inside a li element" do
      html = "<ul>\n<li><a href='https://riseup.net/'>riseup.net</a></li>\n</ul>"
      greencloth = "* [riseup.net -> https://riseup.net/]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "many anchors inside a paragraph" do
      html = "<p>make anchors <a name='here'>here</a> or <a name='maybe-here'>maybe here</a> or <a name='there'>over</a></p>"
      greencloth = "make anchors [# here #] or [# maybe here #] or [# over -> there #]\n"
      assert_renders_greencloth greencloth, html 
    end

    # TODO: there are differents in this test about how cg support writing anchors
    # this is a reduced support of it
    test "anchors and links" do
      html = "<p>link to <a href='/page/anchors#like-so'>anchors</a> or <a href='/page/like#so'>maybe</a> or <a href='#so'>just</a> or <a href='#so'>so</a></p>"
      greencloth = "link to [anchors -> anchors#like so] or [maybe -> like#so] or [just -> #so] or [so -> #so]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "more anchors" do
      html = "<p><a href='#5'>link</a> to a numeric anchor <a name='5'>5</a></p>"
      greencloth = "[link -> #5] to a numeric anchor [# 5 #]\n"
      assert_renders_greencloth greencloth, html 
    end

    test "3 links without /" do
      html = "<p><a href='some'>some</a> and <a href='other'>other</a> and <a href='one_more'>one_more</a></p>"
      greencloth = "[some] and [other] and [one_more]\n"
      assert_renders_greencloth greencloth, html 
    end
  end
end
