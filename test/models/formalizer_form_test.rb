class FormalizerFormTest < ActiveSupport::TestCase

  setup do
    @formalizer = Formalizer.new
  end

  test "add form errors" do  

    assert_raise(ArgumentError) do
      @formalizer.add_form
    end

    assert_raises(TypeError) do
      res = @formalizer.add_form(:valid_id, 'string instead of path')
    end

    assert_raises(Formalizer::PathOrHtmlRequired) do
      res = @formalizer.add_form(:valid_id, {tags: 'tags'})
    end

    assert_nothing_raised(Exception) do
      res = @formalizer.add_form(:valid_id1, {path: 'path_to_form', tags: 'tags'})
    end

    assert_nothing_raised(Exception) do
      # no tags
      res = @formalizer.add_form(:valid_id2, {path: 'path_to_form'})
    end

    res = @formalizer.add_form(:valid_id3, {path: 'path_to_form', tags: 'tags'})
    assert res
  end

end