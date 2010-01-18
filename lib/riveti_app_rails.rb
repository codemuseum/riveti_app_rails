require 'active_resource_tson_format'

module Riveti
  module Helpers
    
    module AssetHelper
      def AssetHelper.compute_asset_host(source)
        Riveti::Constants.r_asset_host % (source.hash % Riveti::Constants.r_asset_host_count)
      end
      
      def AssetHelper.asset_url(asset_type, asset_urn)
        asset_path = asset_type.downcase.pluralize
        asset_ext = asset_path == 'pictures' ? 'img' : 'file'
        path = "/site/#{asset_path}/#{asset_urn}.#{asset_ext}"
        AssetHelper.compute_asset_host(path) + path
      end
      
      def AssetHelper.asset?(asset_type, asset_urn)
        !asset_urn.blank? && !asset_type.blank?
      end
    end
    
    module ViewHelper
      
      # Adds javascripts to the current @page_object or @theme, whichever is being used
      def javascripts(*sources)
        r_object = @page_object || @theme
        r_object.javascripts = sources.collect { |s| path_to_javascript(s) } # = overridden; will simply add to the sources
      end
      
      # Adds stylesheets to the current @page_object or @theme, whichever is being used
      def stylesheets(*sources)
        r_object = @page_object || @theme
        r_object.stylesheets = sources.collect { |s| path_to_stylesheet(s) } # = overridden; will simply add to the sources
      end
      
      # One of the options is :representing => data_path (singular). This helps makes sure the new page represents the right datapath.
      # This is mostly a convenience for the user when editing.
      # Example link_to_new_page 'New Service...', {:representing => 'service'}, {:class => 'html-class-name'}
      #   This will make a link so that the user can easily create a new page representing a service.
      def link_to_new_page(title, options = {}, html_options = {})
        link_to title, '/site/pages/new' + (options.empty? ? '' : "?#{options.to_query}" ), html_options
      end
      
      # Returns the URL to the same page which owns the page object, with options as parameters
      def parent_url(options = {})
        @page_object.page_url + (options.empty? ? '' : "?#{options.to_query}" )
      end
      
      def formatted_site_data_url(format, data_path, options = {})
        return '' if data_path.nil?
        "/site/data.#{format.to_s.downcase}?data_path=#{CGI.escape(data_path)}" + (options.empty? ? '' : "&#{{:options => options}.to_query}" )
      end
      
    end
    
    module FormHelper


      def fields_for_page_object(page_object = @page_object, *args, &proc)
        fields_for "page[form_page_objects][#{page_object.urn}]", page_object, *args, &proc
      end

      # Returns a picture selector
      # Takes f., and what kind of assets this accepts (e.g. [:pictures]), optionally index_nil  For those models that have an asset_urn (belongs_to :picture) that need to edit it.
      def asset_urn_fields(f, accepr_array = [:pictures], index_nil = false)
        out = asset_preview_fields(f, accepr_array, index_nil)
        out += '<div>' + asset_change_link(f, accepr_array) + '</div>'
      end
      
      def asset_change_link(f, accepr_array = [:pictures], text = nil)
        humanized_accepts = accepr_array.collect {|a| a.to_s.singularize.capitalize}.join('/')
        text = text.nil? ? "Change #{humanized_accepts}" : text
        out = ''
        out += "<a class=\"r-assets-selector-change-link\" title=\"Select from the list of existing #{humanized_accepts} or upload a new one.\">#{text}</a>"
        out
      end
      
      def asset_url_text_field(f, accepr_array = [:pages], index_nil = false, field_name = :link)
        out = ''
        if index_nil 
          out += f.text_field field_name, :index => nil, :class => "asset-url asset-url-accepts-#{accepr_array.join('-')}" 
        else 
          out += f.text_field field_name, :class => "asset-url asset-url-accepts-#{accepr_array.join('-')}"
        end
        out
      end
      
      # Returns just the image fields, without any link that says "change" - also outputs hidden fields needed to store which asset is being used.
      def asset_preview_fields(f, accepr_array = [:pictures], index_nil = false)
        out = ''
        if index_nil 
          out += f.hidden_field :asset_urn, :index => nil, :class => "asset-urn"
          out += f.hidden_field :asset_type, :index => nil, :class => "asset-type asset-type-accepts-#{accepr_array.join('-')}" 
        else 
          out += f.hidden_field :asset_urn, :class => "asset-urn"
          out += f.hidden_field :asset_type, :class => "asset-type asset-type-accepts-#{accepr_array.join('-')}"
        end

        unless f.object.picture? 
          out += "<img src=\"/images/default.png\" id=\"#{f.object_name}_asset_img\" class=\"asset-img\"/>"
        else 
          out += "<img src=\"#{f.object.picture_url}\" id=\"#{f.object_name}_asset_img\" class=\"asset-img\"/>"
        end
        out
      end
    end
  end

  module Constants
    
    mattr_reader :r_platform_host
    @@r_platform_host = RAILS_ENV == 'production' ? 'http://www.riveti.com' : 'http://www.riveti.com'
    mattr_reader :r_asset_host
    @@r_asset_host = RAILS_ENV == 'production' ? 'http://asset%d.riveti.com' : 'http://asset%d.riveti.com'
    mattr_reader :r_asset_host_count
    @@r_asset_host_count = RAILS_ENV == 'production' ? 8 : 1
    mattr_reader :r_site_headers_key
    @@r_site_headers_key = 'Site-UID'
    mattr_reader :r_page_title_headers_key
    @@r_page_title_headers_key = 'Page-Title'
    mattr_reader :r_page_urn_headers_key
    @@r_page_urn_headers_key = 'Page-URN'
    mattr_reader :r_page_url_headers_key
    @@r_page_url_headers_key = 'Page-URL'
    mattr_reader :r_page_query_string_key
    @@r_page_query_string_key = 'Page-Query-String'
    mattr_reader :r_page_object_urn_headers_key
    @@r_page_object_urn_headers_key = 'Page-Object-URN'
    mattr_reader :r_user_session_headers_key
    @@r_user_session_headers_key = 'User-Session'
    mattr_reader :r_signature_headers_key
    @@r_signature_headers_key = 'TS-Signature'
    mattr_reader :r_max_signature_age
    @@r_max_signature_age = 45.minutes
    
    @@config = nil
    def self.config
      if @@config.nil?
        @@config = YAML::load(ERB.new(IO.read(File.join(RAILS_ROOT, 'config', 'riveti_app.yml'))).result)[RAILS_ENV]
      end
      @@config
    end
  end
  
  class IncorrectSignature < StandardError; end
  class SignatureTooOld < StandardError; end
end