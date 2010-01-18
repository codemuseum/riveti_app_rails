require 'action_view'
require File.join(File.dirname(__FILE__), 'lib', 'riveti_app_rails')

ActionView::Base.send(:include, Riveti::Helpers::FormHelper)
ActionView::Base.send(:include, Riveti::Helpers::ViewHelper)

# Mime::Type.register_alias "application/json", :tson