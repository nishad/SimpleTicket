#!/usr/local/bin/ruby

#SimpleTicket, Copyright (C) 2006 SimpleTicket
#SimpleTicket comes with ABSOLUTELY NO WARRANTY;
#see LICENSE.
#This is free software, and you are welcome
#to redistribute it under certain conditions; see LICENSE.

require File.dirname(__FILE__) + "/../config/environment" unless defined?(RAILS_ROOT)

# If you're using RubyGems and mod_ruby, this require should be changed to an absolute path one, like:
# "/usr/local/lib/ruby/gems/1.8/gems/rails-0.8.0/lib/dispatcher" -- otherwise performance is severely impaired
require "dispatcher"

ADDITIONAL_LOAD_PATHS.reverse.each { |dir| $:.unshift(dir) if File.directory?(dir) } if defined?(Apache::RubyRun)
Dispatcher.dispatch