require 'test_helper'

class FormalizerTest < ActiveSupport::TestCase

  setup do
    @formalizer = Formalizer.new
    @fields = { test1: 10, test2: 1, test3: 'text value' }
  end

  test "formalizer fill fields" do
    assert_raises(TypeError) do
      @formalizer.fill_fields('not a hash')
    end
  end

  test "fill and export pdf" do

    @formalizer = Formalizer.new

    assert_nothing_raised(Exception) do
      @formalizer.fill_fields(@fields)
    end

    assert_nothing_raised(Exception) do
      @pdf = @formalizer.export_form_to_pdf(:test1, 'test_tag_1')
    end
    assert_instance_of String, @pdf
    assert @pdf.include?('%PDF')

  end

  test "fill and export html" do

    @formalizer = Formalizer.new
    @formalizer.fill_fields(@fields)
    assert_nothing_raised(Exception) do
      @result_html = @formalizer.export_form_to_html(:test1, 'test_tag_1')
    end

    expected_html = Nokogiri::HTML('<formalizer id="test1">___</formalizer><formalizer id="test2" required>___</formalizer><formalizer id="test3">___</formalizer>')
    expected_html.css('formalizer#test1').first.content = '10'
    expected_html.css('formalizer#test2').first.content = 'Two'
    expected_html.css('formalizer#test3').first.content = 'text value'

    assert expected_html.to_s == @result_html

  end
   

  test "tags" do

    expected_tags = {"test_tag_1"=>[:test1, :test2, :test3], "test_tag_2"=>[:test1, :test2]}
    formalizer = Formalizer.new
    expected_tags.each do |tag_key, tag_value|
      assert_equal expected_tags[tag_key], formalizer.tags[:form_fields][tag_key]
    end
  end

end