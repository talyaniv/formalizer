class FormalizerFormFieldTest < ActiveSupport::TestCase


  test "add form field" do

    formalizer = Formalizer.new

    assert_raises(ArgumentError) do
      formalizer.add_form_field
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      formalizer.add_form_field({})
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      formalizer.add_form_field({type: :enum})
    end

    assert_raises(Formalizer::WrongValueClass) do
      formalizer.add_form_field({id: 'test10', name: :a_symbol})
    end

    assert_raises(Formalizer::FormFieldParamMissing) do
      formalizer.add_form_field({id: 'test10', name: ''})
    end

    assert_raises(Formalizer::NotUniqueId) do
      formalizer.add_form_field({id: 'test10', name: 'test 10'})
      formalizer.add_form_field({id: 'test10', name: 'test 10 again'})
    end

    current_length = formalizer.form_fields.length
    formalizer.add_form_field({id: 'test11', name: 'test 11'})
    expected = current_length + 1
    assert_equal expected, formalizer.form_fields.length
  end
  
end