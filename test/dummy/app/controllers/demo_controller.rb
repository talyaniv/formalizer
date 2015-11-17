class DemoController < ApplicationController

  # Holds the main demo activity control
  # Will generate a user-input form fill it with user input and export HTML/PDF


  # Formalizer's generated form has no authenticity_token field. 
  # This field can (and should) be used, either manually or automatically,
  # by replacing the generated <form> tag with Rails form_tag or form_for(active_record model) helper.
  # To skip authenticity protection in this controller, uncomment the following line at your own risk:
  # protect_from_forgery :only => [:index]

  def index

    # deault root view

    # navbar current view:
    @page = 'demo'

    # the form is submitted to the same page, handling the POST method first:
    fill_form and return if request.method == 'POST'

    # Letting Formalizer generate a user input form
    # We limit fields only to 'nda' tag. Other config tags relate to unit tests,
    # and are not relevant to the demo's nda form

    fill_form = Formalizer.new.generate_fields_form(I18n.locale, '', 'nda')

    # The generated form is ready to use as is, but we're spicing it up a bit with Bootswatch classes:
    fill_form_html = Nokogiri::HTML(fill_form)
    auth_token_field = Nokogiri::XML::Node.new('input', fill_form_html)
    fill_form_html.css('div').each{|div| div['class'] = 'form-group'}
    fill_form_html.css('label').each{|label| label['class'] = 'col-lg-4 control-label'}
    fill_form_html.css('div.form-group input:not([type="reset"]):not([type="submit"])').wrap('<div class="col-lg-8">')
    fill_form_html.css('div.form-group select').wrap('<div class="col-lg-8">')
    fill_form_html.css('div.form-group input').each{|input| input['class'] = 'form-control'}
    fill_form_html.css('div.form-group select').each{|select| select['class'] = 'form-control'}
    fill_form_html.css('input[type="reset"]').each{|input| input['class'] = 'btn btn-default'}
    fill_form_html.css('input[type="submit"]').each{|input| input['class'] = 'btn btn-primary'}
    fill_form_html.css('div.form-group:last-child').wrap('<div class="form-buttons form-group">')
    fill_form_html.at_css('div.form-buttons > div')['class'] = 'col-lg-8 col-lg-offset-2'

    # Adding authenticity token. The following lines can be commented out if
    # the protect_from_forgery line is uncommented (see comments at the top)
    form_tag = fill_form_html.at_css('form')
    form_tag['class'] = 'form-horizontal'
    auth_token_field = Nokogiri::XML::Node.new('input', fill_form_html)
    auth_token_field['type'] = 'hidden'
    auth_token_field['name'] = 'authenticity_token'
    auth_token_field['value'] = form_authenticity_token
    auth_token_field.parent = form_tag

    # Finalizing and wrapping the form for view
    @fill_details = fill_form_html.at_css('form').to_s

  end


  # Form POSTed and processed here

  def fill_form
    # How do you want your filled form served?
    export_to = :pdf unless params['export_PDF'].nil?
    export_to = :html unless params['export_HTML'].nil?

    # Keeping only necessary params key/values
    params.reject!{|key, value| %w(authenticity_token controller action export_PDF export_HTML).include?key}

    # Sanitizing
    sanitized_params = params.inject({}) do |hash, (k, v)|
      begin
        v = ActionController::Base.helpers.sanitize(v.to_s)
        v = ActionController::Base.helpers.strip_tags(v)
        hash.merge(k => v)
      rescue
        puts "Could not sanitize: #{hash}"
        return
      end
    end

    # Filling and exporting
    formalizer = Formalizer.new
    formalizer.fill_fields(sanitized_params.symbolize_keys)
    case export_to
      when :pdf
        # pdf will be downloaded at client
        pdf_stream = formalizer.export_form_to_pdf(:form1, 'nda')
        send_data pdf_stream, {filename: 'demo.pdf', disposition: 'attachment'}
      when :html
        # html will be rendered inline
        render html: formalizer.export_form_to_html(:form1, 'nda').html_safe
    end
  end


  # Demo page has a link to this action.
  # Renders the empty, unfilled demo template

  def html_template
    render html: File.read('config/form1.html').html_safe
  end

end
