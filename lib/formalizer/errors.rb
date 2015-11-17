class Formalizer
  class FormFieldParamMissing < StandardError; end
  class NotUniqueId < StandardError; end
  class WrongValueClass < StandardError; end
  class WrongValue < StandardError; end
  class FileNotFound < StandardError; end
  class WrongFileContent < StandardError; end
  class WrongFormTemplate < StandardError; end
  class FormFillError < StandardError; end
  class RequiredField < StandardError; end
  class FormTemplateError < StandardError; end
  class ConfigError < StandardError; end
  class PathOrHtmlRequired < StandardError; end
  class FieldNotFound < StandardError; end
end