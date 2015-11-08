class UtilsTest < ActiveSupport::TestCase

  # Utils tests

  test "file not found" do
    assert_raises(Formalizer::FileNotFound) do
      Formalizer::Utils.find_file('/test/dummy/blabla')
    end
    assert_raises(Formalizer::FileNotFound) do
      Formalizer::Utils.find_file('blabla')
    end
    assert_raises(Formalizer::FileNotFound) do
      Formalizer::Utils.find_file('')
    end
  end

  test "file found" do
    config_file_contents = Formalizer::Utils.find_file(File.expand_path('test/dummy/config/formalizer.yml'))
    assert_instance_of String, config_file_contents
    config_file_contents = Formalizer::Utils.find_file('formalizer.yml')
    assert_instance_of String, config_file_contents
  end
end