require 'test_helper'

class FormalizerTest < ActiveSupport::TestCase

  # setup do
  # end

  test "tags" do

    expected_tags = {"tag1"=>[:test1, :test2], "tag2"=>[:test1, :test3], "tag3"=>[:test3]}
    formalizer = Formalizer.new
    expected_tags.each do |tag_key, tag_value|
      assert_equal expected_tags[tag_key], formalizer.tags[:form_fields][tag_key]
    end
  end

end