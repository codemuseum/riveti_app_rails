# class Crawl < ActiveRecord::Base
#   include RivetiObjectMethods

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