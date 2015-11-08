class FormalizerConfigTest < ActiveSupport::TestCase

  test "invalid config" do

    assert_raises(Formalizer::ConfigError) do
      formalizer = Formalizer.new('alternative_invalid_config1.yml')
    end

    assert_raises(Formalizer::ConfigError) do
      formalizer = Formalizer.new('alternative_invalid_config2.yml')
    end

    ['', 'wrong path'].each do |wrong_path|
      formalizer = Formalizer.new(wrong_path)
      assert_empty formalizer.form_fields
      assert_empty formalizer.forms
    end

  end

  test "valid config" do

    asserts = lambda do |formalizer|
      assert_not_empty formalizer.form_fields
      assert_instance_of Hash, formalizer.forms
    end

    formalizer = Formalizer.new
    asserts.call(formalizer)
    formalizer = Formalizer.new('formalizer.yml')
    asserts.call(formalizer)

  end

end