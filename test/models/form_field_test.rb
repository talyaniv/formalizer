class FormFieldTest < ActiveSupport::TestCase

  # setup do
  # end

  # FormField tests

  test "form field invalid params" do
    assert_raises(ArgumentError) do
      # no params
      form_field = Formalizer::FormField.new()
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      # missing name, default locale
      form_field = Formalizer::FormField.new({name: ''})
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      # missing name, localized
      form_field = Formalizer::FormField.new({name: {en: 'exists', es: ''}})
    end


    assert_raises(Formalizer::FormFieldParamMissing) do
      # missing enumeration
      form_field = Formalizer::FormField.new({
        name_en: 'test',
        field_type: :enum
      })
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      # insufficient enumeration
      form_field = Formalizer::FormField.new({
        name: 'test',
        field_type: :enum,
        enumeration: {en: ['res1', 'res2'], es: ['res1']}
      })
    end

  end

  test "form field valid params" do

    # simple name
    form_field = Formalizer::FormField.new({name: 'test'})
    assert_equal form_field.name, 'test'
    assert_instance_of String, form_field.id
    assert_operator form_field.id.length, :>, 0

    # localized names
    form_field = Formalizer::FormField.new({name: {en: 'test-English', es: 'test-Spanish'}})
    assert_equal form_field.name, 'test-English'
    assert_equal form_field.name(:es), 'test-Spanish'

    # custom id
    form_field = Formalizer::FormField.new({id: 'test1', name: 'test'})
    assert_equal form_field.id, 'test1'

    # enumeration
    form_field = Formalizer::FormField.new({
      name: 'test',
      field_type: :enum,
      enumeration: ['res1', 'res2', 'res3']
    })
    assert_equal form_field.enumeration, ['res1', 'res2', 'res3']
  end

  test "set form field value" do
    form_field = Formalizer::FormField.new({name: 'test'})
    form_field.value = 'success'
    assert_equal form_field.value, 'success'
  end

  test "html render" do
    form_field = Formalizer::FormField.new({id: 'test1', name: 'test'})
    assert_nothing_raised(Exception) do
      @rendered = form_field.render_html(Nokogiri::HTML('')).to_s
    end
    assert @rendered == "<input type=\"text\" value=\"\" id=\"test1\" name=\"test1\">"

    form_field = Formalizer::FormField.new({
      id: 'test2',
      name: 'test',
      field_type: :enum,
      enumeration: {
        en: ['a', 'b', 'c'],
        es: ['d', 'e', 'f']
      }
    })

    assert_nothing_raised(Exception) do
      @rendered = form_field.render_html(Nokogiri::HTML('')).to_s
    end
    assert @rendered == "<select id=\"test2\" name=\"test2\"><option value=\"0\">a</option>\n<option value=\"1\">b</option>\n<option value=\"2\">c</option></select>"

    assert_nothing_raised(Exception) do
      @rendered = form_field.render_html(Nokogiri::HTML(''), :es).to_s
    end
    assert @rendered == "<select id=\"test2\" name=\"test2\"><option value=\"0\">d</option>\n<option value=\"1\">e</option>\n<option value=\"2\">f</option></select>"



    form_field = Formalizer::FormField.new({
      id: 'test2',
      name: 'test',
      field_type: :enum,
      enumeration: {
        en: ['a', 'b', 'c'],
        es: ['d', 'e', 'f']
      },
      default_value: 1
    })
    assert_nothing_raised(Exception) do
      @rendered = form_field.render_html(Nokogiri::HTML('')).to_s
    end
    assert @rendered == "<select id=\"test2\" name=\"test2\"><option value=\"0\">a</option>\n<option value=\"1\" selected>b</option>\n<option value=\"2\">c</option></select>"

    assert_nothing_raised(Exception) do
      @rendered = form_field.render_html(Nokogiri::HTML(''), :es).to_s
    end
    assert @rendered == "<select id=\"test2\" name=\"test2\"><option value=\"0\">d</option>\n<option value=\"1\" selected>e</option>\n<option value=\"2\">f</option></select>"

  end

end