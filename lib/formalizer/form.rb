class Formalizer


  # Holds a single form template and its binding

  class Form

    # Constructor
    # * +id+ - Unique textal identifier for the form
    # * +path_or_html+ - Either a path to a template html file, or a raw html

    def initialize id, path_or_html
      validate id, path_or_html
      parse(path_or_html)
      validate_template
      @id = id
    end


    # Binds fields to a template
    # * +fields+ - Hash of id => FormField object. Fields that do not exist in the form will be ignored.
    # * Raises an error if a required field is not present in the fields param,
    #   or if it is present but doesn't have a value.

    def fill fields
      raise TypeError unless fields.is_a?(Hash)

      @html_template.css('formalizer').each do |html_field|
        field_id = html_field.attributes['id'].value
        form_field = fields[field_id.to_sym]

        # raising error if field is required but not found in fields param, otherwise skipping this field
        if form_field.nil?
          required_attribute = html_field.attributes['required']
          field_required = !required_attribute.nil? && (required_attribute.value == '' || required_attribute.value == 'true')
          raise RequiredField, "field #{field_id} is required" if field_required
          next
        end

        # field found in field params, so we don't care if it's required or not
        html_field.content = form_field.value

      end
    end


    # Exports the filled form into a PDF file uwing Wicked PDF gem

    def export_to_pdf filename = 'pdf'
      # replacing html image tags with wicked_pdf tags
      html = @html_template.to_s
      @html_template.css('img').each do |image_tag|
        html.gsub!(image_tag.to_s, replace_tag(image_tag, 'src'))
      end
      @html_template.css('link').each do |rel_tag|
        html.gsub!(rel_tag.to_s, replace_tag(rel_tag, 'href'))
      end
      WickedPdf.new.pdf_from_string(html)
    end


    # Exports the filled form into a raw html string

    def export_to_html
      @html_template.to_s
    end


    # Private methods

    private


    # Validates initializer.
    # Raises errors if cannot initialize form from path or raw html
    # * +id+ - Unique textal identifier for the form
    # * +path_or_html+ - Either a path to a template html file, or a raw html

    def validate id, path_or_html
      unless (id.is_a?String) || (id.is_a?Symbol)
        raise WrongValueClass, 'form id should be a String or Symbol'
      end
      raise WrongValueClass, 'path/html should be a String' unless path_or_html.is_a?String
    end


    # Parses the path/html into a final html template,
    # Creates and fills @html_template variable for further binding.
    # * +path_or_html+ - Either a path to a template html file, or a raw html

    def parse path_or_html
      # trying HTML first
      @html_template = Nokogiri::HTML(path_or_html)
      return if @html_template.css('formalizer').length > 0 # html indeed, parsed.

      # not html, trying path
      error_message = 'not a file and not valid html with <formalizer> tag/s'
      html_file_content = Utils::find_file(path_or_html)
      @html_template = Nokogiri::HTML(html_file_content)
      return if @html_template.css('formalizer').length > 0 # file opened, parsed.

      raise WrongFormTemplate, error_message
    end


    # Validates that the html template is usable
    # Raises errors if <formalizer> tags don't contain id attribute

    def validate_template
      @html_template.css('formalizer').each do |html_field|
        raise FormTemplateError if html_field.attributes['id'].nil?
      end
    end


    # replacing html references/assets references with absolute file paths for PDF export

    def replace_tag tag, attribute
      final_path = Utils::final_path(tag[attribute])
      return '' if final_path.empty?
      tag[attribute] = final_path
      return tag.to_s
    end

  end

end