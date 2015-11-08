class Formalizer

  class Form

    def initialize id, path_or_html
      validate id, path_or_html
      parse(path_or_html)
      validate_template
      @id = id
    end

    def fill fields
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

    def export_to_pdf filename = 'pdf'
      pdf = WickedPdf.new.pdf_from_string(@html_template.to_s)
    end


    private

    def validate id, path_or_html
      unless (id.is_a?String) || (id.is_a?Symbol)
        raise WrongValueClass, 'form id should be a String or Symbol'
      end
      raise WrongValueClass, 'path/html should be a String' unless path_or_html.is_a?String
    end

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

    def validate_template
      @html_template.css('formalizer').each do |html_field|
        raise FormTemplateError if html_field.attributes['id'].nil?
      end
    end

  end

end