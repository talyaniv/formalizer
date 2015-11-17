class String
  def to_bool
    return true   if self == true   || self =~ (/(true|t|yes|y|1)$/i)
    return false  if self == false  || self.blank? || self =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class Formalizer

  # Holds attributes for a single field in a form.
  #
  # === Attributes
  #
  # * +id+ - Unique textal identifier for the field. See generate_id
  # * +field_type+ - One of possible options described in TYPES constant
  # * +name+ - field name in current locale. For custom locale use method: name(locale)
  # * +enumeration+ - if field_type is :enum or :multiple, list of options for enumeration in current locale
  #                   for custom locale use method: enumeration(locale)
  # * +validation+ - a hash with validation rules, TBD
  # * +default_value+ - the default value in current locale. for custom locale use method: defaut_value(locale)

  class FormField
    attr_reader :id, :field_type, :name, :enumeration, :validation, :default_value, :value

    TYPES = {
      boolean: 1,
      number: 2,
      text: 3,
      enum: 4,
      multiple: 5
    }

    # Prefixes that can be localized in constructor params. See initialze and examples below

    LOCALIZED_TYPES = [
      :name,
      :enumeration,
      :default_value
    ]



    # see usage examples at the end:

    def initialize params
      validate_params params

      # populating properties

      @field_type = params[:field_type].nil? ? TYPES[:text] : TYPES[params[:field_type].to_sym]
      localize params
      @validation = params[:validation] || {}
      @id = params[:id] || generate_id
      @default_value = params[:default_value] unless params[:default_value].nil?
      @value = nil
    end


    # getters

    def name locale = I18n.locale
      @localized[:name][locale] || ''
    end

    def enumeration locale = I18n.locale
      @localized[:enumeration][locale] || []
    end

    def default_value locale = I18n.locale
      return @localized[:default_value][locale]
    end

    def value locale = I18n.locale
      return '' if @value.nil?
      return send("#{TYPES.key(@field_type)}_value", locale)
    end


    # setters

    # Since we deal with html, value must be a String

    def value= new_value
      validated = send("validate_#{TYPES.key(@field_type)}_value", new_value)
      @value = validated
    end


    # Renders the field as HTML control
    # * +parent_node+ - the HTML parent under which to render (needed by Nokogiri)
    # * +locale+ - localized input. Relevant if field_type is enum or multiple

    def render_html parent_node, locale = I18n.locale
      inp = send("render_html_#{TYPES.key(@field_type)}", parent_node, locale)
      inp['id'] = @id
      inp['name'] = @id
      return inp
    end


    private

    # generates a text id to use inside forms
    # strips non alpfanumeric characters from name, lowercases the result
    # and replaces whitespaces with '_'
    # adds a unique hash at the end
    # e.g. 'First Name (required)' -> 'first_name_required_f5f6f0ae0717937a039488c5b6163d6f'

    def generate_id
      base_name = @localized[:name][:en] || @localized[:name].values.first || ''
      underscored_name = base_name.gsub(/[^0-9a-z ]/i, '').downcase.gsub(/\s+/, '_') << '_'
      underscored_name += Digest::MD5.new.update(Time.now.to_i.to_s).hexdigest
    end




    # creates localized hash from initializer params with default locale
    # example: initializer params { name: 'Gender' ....}
    # result: {name: {en: 'Gender'}}
    # example: initializer params { name: {en: 'Gender', es: es: 'Género'} ... }
    # result: {name: {en: 'Gender', es: 'Género'}}

    def localize params
      @localized = {}
      LOCALIZED_TYPES.each do |localized_type|
        if params[localized_type].class == Hash
          # params are already localized per locale
          @localized[localized_type] = params[localized_type]
        else
          @localized[localized_type] = {I18n.locale => params[localized_type]}
        end
      end
    end


    # validate initializer params and raises exceptions unless validation passes

    def validate_params params

      raise FormFieldParamMissing, 'params must be a hash' unless params.class == Hash

      # validating that at least one name_{locale} exists
      raise FormFieldParamMissing, 'name is requireed' if params[:name].nil?

      # validate that names are non-empty strings
      names = params[:name].class == Hash ? params[:name].values : [params[:name]]
      names.each do |name_value|
        raise WrongValueClass, 'name should be a String' unless (name_value.is_a?String)
        raise FormFieldParamMissing, 'name cannot be empty' if name_value.empty?
      end

      # validating that enumeration exists if field_type is enum or multiple
      if [:enum, :multiple].include?(params[:field_type])
        error_message = "enumeration array of >1 items requireed if field_type is enum/multiple"
        enumerations = params[:enumeration].class == Hash ? params[:enumeration].values : [params[:enumeration]]
        raise FormFieldParamMissing, error_message if enumerations.length == 0
        enumerations.each do |enumeration|
          if (!enumeration.is_a?Array) || (enumeration.length < 2)
            raise FormFieldParamMissing, error_message
          end
        end
      end

      # validates param types

    end



    # Value validators

    def validate_boolean_value new_value
      new_value = new_value.to_bool if new_value.is_a?String
      is_boolean = (!!(new_value) == new_value)
      raise WrongValueClass, 'value should be boolean' unless is_boolean
      return new_value
    end

    def validate_number_value new_value
      if new_value.is_a?String
        new_value = (new_value.include?'.') ? new_value.to_f : new_value.to_i
      end
      is_number = ((new_value.is_a?Fixnum) || (new_value.is_a?Float))
      raise WrongValueClass, 'value should be a number' unless is_number
      return new_value
    end

    def validate_text_value new_value
      raise WrongValueClass, 'value whould be a string' unless new_value.is_a?String
      return new_value
    end

    def validate_enum_value new_value
      new_value = new_value.to_i if new_value.is_a?String
      raise WrongValueClass, 'value should be a fixnum' unless new_value.is_a?Fixnum
      raise WrongValueClass, 'value should be >= 0' if new_value < 0
      min_enumeration_length = @localized[:enumeration].values.map{|enumeration| enumeration.length}.min
      raise WrongValue, 'value should be within enumeration range' if new_value >= min_enumeration_length
      return new_value
    end

    def validate_multiple_value new_value
      new_value = new_value.to_i if new_value.is_a?String
      raise WrongValueClass, 'value should be an array' unless new_value.is_a?Array
      min_enumeration_length = @localized[:enumeration].values.map{|enumeration| enumeration.length}.min
      raise WrongValueClass, 'array values should be >= 0' if new_value.min < 0
      raise WrongValue, 'values should be within enumeration range' if new_value.max >= min_enumeration_length
      return new_value
    end




    # value parsers: return type dependent value

    def boolean_value locale
      @value ? '&#10004;' : '-' # TODO: render as checkbox?
    end

    def number_value locale
      @value ? @value.to_s : ''
    end

    def text_value locale
      @value || ''
    end

    def enum_value locale
      @value.nil? ? '' : @localized[:enumeration][locale][@value].to_s
    end

    def multiple_value locale
      @value.nil? ? '' : @value.map{|val| @localized[:enumeration][locale][val].to_s}
    end


    # HTML renderers


    def render_html_boolean parent_node, locale = I18n.locale
      inp = Nokogiri::XML::Node.new('input', parent_node)
      inp['type'] = 'checkbox'
      inp['checked'] = 'true' if @default_value == true
      return inp
    end

    def render_html_number parent_node, locale = I18n.locale
      inp = Nokogiri::XML::Node.new('input', parent_node)
      inp['type'] = 'number'
      inp['value'] = @default_value if @default_value
      return inp
    end

    def render_html_text parent_node, locale = I18n.locale
      inp = Nokogiri::XML::Node.new('input', parent_node)
      inp['type'] = 'text'
      inp['value'] = self.default_value(locale)
      return inp
    end

    def render_html_enum parent_node, locale = I18n.locale
      return select_with_options(parent_node, locale)
    end

    def render_html_multiple parent_node, locale = I18n.locale
      select_tag = select_with_options(parent_node, locale)
      select_tag['multiple'] = 'true'
      return select_tag
    end

    def select_with_options parent_node, locale = I18n.locale
      inp = Nokogiri::XML::Node.new('select', parent_node)
      enumeration(locale).each_with_index do |enum, index|
        enum_option = Nokogiri::XML::Node.new('option', inp)
        enum_option['value'] = index.to_s
        enum_option.content = enum
        enum_option['selected'] = 'true' if default_value == index
        enum_option.parent = inp
      end
      return inp
    end



    # usage example 1 - enumerated, default locale:
    # Formalizer::FormField.new({
    #                            id: 'gender',
    #                            name: 'Gender',
    #                            field_type: :enum,
    #                            enumeration: ['male', 'female', 'irrelevant'],
    #                            default_value: 2})
    # usage example 2 - enumerated, localized:
    # Formalizer::FormField.new({
    #                            id: 'gender',
    #                            name: {
    #                              en: 'Gender',
    #                              es: 'Género'
    #                            },
    #                            field_type: :enum,
    #                            enumeration: {
    #                              en: ['male', 'female', 'irrelevant'],
    #                              es: ['masculino', 'femenino', 'irrelevante']
    #                            },
    #                            default_value: 2})
    # usage example 2 - text, localized:
    # Formalizer::FormField.new({
    #                            id: 'first_name',
    #                            name: {
    #                              en: 'First Name',
    #                              es: 'Nombre de pila'
    #                            },
    #                            field_type: :text,
    #                            default_value: {
    #                              en: John,
    #                              es: Juan
    #                            }})

  end
end

