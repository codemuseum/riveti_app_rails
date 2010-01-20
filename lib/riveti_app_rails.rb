module Riveti

  module Constants    
    mattr_reader :r_platform_host
    @@r_platform_host = RAILS_ENV == 'production' ? 'http://www.riveti.com' : 'http://riveti-development.heroku.com'
    mattr_reader :r_asset_host
    @@r_asset_host = RAILS_ENV == 'production' ? 'http://asset%d.riveti.com' : 'http://asset%d.riveti.com'
    mattr_reader :r_site_headers_key
    @@r_site_headers_key = 'Site-UID'
    mattr_reader :r_signature_headers_key
    @@r_signature_headers_key = 'R-Signature'
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