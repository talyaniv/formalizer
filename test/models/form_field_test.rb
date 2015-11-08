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

end