class FormTest < ActiveSupport::TestCase

  setup do
    @valid_html = <<-eof
    <formalizer id="id1">___</formalizer><formalizer id="id2" required>___</formalizer>
    eof

    @valid_fields = {
      id1: Formalizer::FormField.new({id: 'id1', name: 'name1'}),
      id2: Formalizer::FormField.new({id: 'id2', name: 'name3'})
    }
  end

  test "form invalid params" do

    assert_raises(ArgumentError) do
      # no params
      form_field = Formalizer::Form.new()
    end

    assert_raises(Formalizer::WrongValueClass) do
      form_field = Formalizer::Form.new(['array instead of string'], ['array instead of string'])
      form_field = Formalizer::Form.new('string', ['array instead of string'])
      form_field = Formalizer::Form.new(['array instead of string'], 'string')
      form_field = Formalizer::Form.new(9, 'string')
    end

  end


  test "from from invalid path" do

    assert_raises(Formalizer::FileNotFound) do
      form_field = Formalizer::Form.new(:valid_id, 'wrong path')
    end

  end


  test "form from valid path but wrong html" do

    assert_raises(Formalizer::WrongFormTemplate) do
      form_field = Formalizer::Form.new(:valid_id, 'invalid_html_no_formalizer_tags.html')
      form_field = Formalizer::Form.new(:valid_id, 'invalid_html_formalizer_tags_without_ids.html')
    end

  end



  test "form from invalid direct html" do

    assert_raises(Formalizer::FileNotFound) do
      invalid_html = '<html><body>valid html, but without formalizer tags</body></html>'
      # Nokogiri will fail finding <formalizer> tags, so form will think it's a path
      form_field = Formalizer::Form.new(:valid_id, invalid_html)
    end

    assert_raises(Formalizer::FormTemplateError) do
      # <foramzlier> tags must contain id attribute
      invalid_html = '<html><body>formalier tag without id <formalizer>___</formalizer></body></html>'
      form = Formalizer::Form.new(:form_id, invalid_html)
    end

  end


  test "new form from path" do

    form = Formalizer::Form.new(:form_id, @valid_html)
    assert_instance_of Formalizer::Form, form

  end

  test "fill form with missing param" do

    assert_raises(ArgumentError) do
      form = Formalizer::Form.new(:form_id, @valid_html)
      form.fill
    end

  end

  test "fill form with missing required fields" do

    assert_raises(Formalizer::RequiredField) do
      form = Formalizer::Form.new(:form_id, @valid_html)
      form_field = Formalizer::FormField.new({id: 'id1', name: 'name1'})
      form_field.value = 'text1'
      form.fill({id1: form_field})
    end

  end

  test "fill form" do

    assert_nothing_raised(Formalizer::RequiredField) do
      form = Formalizer::Form.new(:form_id, @valid_html)
      form.fill(@valid_fields)
    end

  end

  test "export to pdf" do
    form = Formalizer::Form.new(:form_id, @valid_html)
    form.fill(@valid_fields)
    @pdf = nil
    assert_nothing_raised(Exception) do
      @pdf = form.export_to_pdf
    end
    assert_instance_of String, @pdf
    assert @pdf.include?('%PDF')
  end
end