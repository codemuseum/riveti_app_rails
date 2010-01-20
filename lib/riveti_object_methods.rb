# class Crawl < ActiveRecord::Base
#   include RivetiObjectMethods
require 'net/http'

module RivetiObjectMethods
  
  def self.included(klass)
    unless klass.included_modules.include?(InstanceMethods)
      klass.extend ClassMethods
      klass.send :include, InstanceMethods
    end
  end
  
  module ClassMethods

  end
  
  module InstanceMethods
    def send_events(events_hash)
      Net::HTTP.post(URI.parse("#{Riveti::Constants.r_platform_host}/events.json"), "r_api_key=#{ThriveSmart::Constants.config['api_key']}&events=#{events_hash.to_json}", remote_headers)
    end
  
    def remote_headers(params_hash = nil)
      set_raw_signature

      { Riveti::Constants.r_signature_headers_key => "#{@raw_signature_string}&r_sig=#{CGI::escape(compute_signature)}" }
    end
    
    def set_raw_signature
      @raw_signature_string = "r_sig_api_key=#{CGI::escape(ThriveSmart::Constants.config['api_key'])}&r_sig_time=#{CGI::escape(Time.now.to_f.to_s)}"
    end

    def compute_signature
      Digest::MD5.hexdigest([@raw_signature_string, ThriveSmart::Constants.config['secret_key']].join)
    end

    def signature_header
      "#{@raw_signature_string}&r_sig=#{CGI::escape(compute_signature)}"
    end
    
  end

  class Event < ActiveResource::Base
    self.site = "#{Riveti::Constants.r_platform_host}/site"
    self.collection_name = 'data' # FIXME when rails knows that 2 pieces of data is still "data" and not "datas"
    self.format = :tson

    def self.prepare(site_uid, page_object_urn, user_session_id)
      headers[Riveti::Constants.r_site_headers_key] = site_uid
      headers[Riveti::Constants.r_user_session_headers_key] = user_session_id
      headers[Riveti::Constants.r_page_object_urn_headers_key] = page_object_urn
    end

    def self.find_data(data_path, options = {})
      find(:all, :params => {:data_path => data_path, :options => options})
    end
  end
end