module Formalizer

  # Package is the main Formalizer object you use to create, fill and export html documents from user-input.
  # The user input fields can be preset in a config/formalizer.yml file
  # or programatically, by calling add_form_field

  class Package


    # EMPTY_CONFIG constant used to initialize config if not given from YAML file

    EMPTY_CONFIG = {
      form_fields: {},
      forms: {}
    }

    attr_reader :form_sources, :forms, :form_fields



    # Constructor
    # Tries loading configuration from YAML file, falling back to an empty config
    # Caching form fields and form targets (a target can be a path or actual html)

    def initialize
      load_config

      @form_fields = {}
      @form_sources = {}
      @forms = {}
      @tags = {form_fields: {}, forms: {}}
      @config[:form_fields].each do |key, value|
        add_form_field value.merge(id: key)
      end
      @config[:forms].each do |key, value|
        add_form key, value
      end
    end


    # Adds a FormField object to the hash
    # Aalidates that the id is unique
    # * +form_field_hash+ - a hash describing the form field.
    #                       See examples at the end of formalizer/form_field.rb

    def add_form_field form_field_hash
      # unique id validation
      raise NotUniqueId unless @form_fields[form_field_hash[:id]].nil?

      # adding to hash
      @form_fields[form_field_hash[:id]] = FormField.new(form_field_hash)

      # handling tags
      add_tags :form_fields, form_field_hash
    end


    # Adds a form source (path or html) to the forms hash
    # Validates that the id is unique
    # * +form_id+ - a unique id to the form
    # * +form_hash+ - a hash containing form path/html and tags

    def add_form form_id, form_hash, tags = nil
      # unique id validation
      raise NotUniqueId unless @form_sources[form_id].nil?

      # adding to hash
      @form_sources[form_id] = form_hash[:path]

      # handling tags
      add_tags :forms, form_hash
    end


    # Fills one form field with content
    # * +field_id+ - the field id
    # * +field_value+ - value to fill the field

    def fill_field field_id, field_value
      @form_fields[field_id].value = field_value
    end


    # Fills multiple form fields with content
    # chash of {id: value} objects to fill multuple fields

    def fill_fields field_params
      field_params.each do |field_id, field_value|
        fill_field(field_id, field_value)
      end
    end


    # Exports a form to pdf
    # * +form_id+ - the form id to export

    def export_form_to_pdf form_id, tag = nil
      form = get_form(form_id)
      form_fields = tag.nil? ? @form_fields : @form_fields.select{|key, ff| @tags[:form_fields][tag].include?(ff.id)}
      form.fill(form_fields)
      return form.export_to_pdf
    end



    # Private methods

    private


    # Loads config from YAML file
    # Raises an error if YAML file is ill formatted
    # Puts a warning if not YAML file not found

    def load_config
      # searching in paths
      @config = nil
      begin
        config_file_content = Utils::find_file('formalizer.yml') # will raise an exception if not found
        @config ||= YAML.load(config_file_content)
      rescue Errors::FileNotFound
        # ok, no config... not a disaster
        puts "YAML Not found in #{File.expand_path(path)}"
      rescue Psych::SyntaxError
        # config found but ill-formatted YAML
        raise "YAML Syntax Error in #{file_path}"
      end

      # Fallback to an empty config
      @config ||= EMPTY_CONFIG

      # YAML is translated to quoted keys, FormField expects symbols:
      @config.deep_symbolize_keys!

      validate_config
    end


    # Validates that the config file has the necessary ingredients

    def validate_config
      # checking that all field ids are unique
      [:form_fields, :forms].each do |config_item|
        ids = @config[config_item].keys
        raise "Config form_fields - keys must be unique" if ids.uniq.length != ids.length
      end
    end


    # Gets a form instance
    # Returning cached instance or caching one and returning it

    def get_form form_id
      form = @forms[form_id] || lambda{@forms[form_id] = Form.new(form_id, @form_sources[form_id])}.call
    end



    # Handles form_field and form tags
    def add_tags tag_type, object_hash
      unless object_hash[:tags].nil?
        tags = (object_hash[:tags].is_a?Array) ? object_hash[:tags] : [object_hash[:tags]]
        tags.each do |tag_name|
          @tags[tag_type][tag_name] ||= []
          @tags[tag_type][tag_name] << object_hash[:id]
        end
      end
    end
  end
end