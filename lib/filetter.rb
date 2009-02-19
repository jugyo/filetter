# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$: << File.dirname(__FILE__) + '/plugins'

require 'pathname'
require 'readline'
require 'singleton'

require 'filetter/version'
require 'filetter/file_info'
require 'filetter/observer'

Thread.abort_on_exception = true

module Filetter
  class << self
    def run(options = {})
      default_option = {:conf_file => '.filetter',:pattern => './**/*', :interval => 1, :debug => false}
      options = default_option.merge(options)
      load options[:conf_file]
      Observer.run(default_option.merge(options))
    end

    def add_hook(*args, &block)
      Observer.instance.add_hook(*args, &block)
    end
  end
end
