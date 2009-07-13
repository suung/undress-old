require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class RainbowCloth::GreenClothTest < Test::Unit::TestCase
  def assert_renders_greencloth(greencloth, html)
    assert_equal greencloth, RainbowCloth.new(html).to_greencloth
  end

  context "Converting HTML to greencloth" do
    test "converts nested tags" do
      assert_renders_greencloth "h2. _this is *very* important_\n", "<h2><em>this is <strong>very</strong> important</em></h2>"
    end
  end
end
