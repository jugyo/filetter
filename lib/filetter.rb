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
      @options = { :conf_dir => '~/.filetter/',
                   :conf_file_name => 'conf',
                   :pattern => './**/*',
                   :interval => 1,
                   :debug => false }.merge(options)

      @conf_dir = File.expand_path(@options[:conf_dir])
      @conf_file = @conf_dir + @options[:conf_file_name]

      check_conf_dir_and_file()
      load @conf_file

      Observer.run( :pattern => @options[:pattern],
                    :interval => @options[:interval],
                    :debug => @options[:debug] )
    end

    def check_conf_dir_and_file
      Dir.mkdir(@conf_dir) unless File.exist?(@conf_dir)
      $: << @conf_dir
      unless File.exist?(@conf_file)
        File.open(@conf_file, 'w') do |io|
          io.puts "require 'sample'"
        end
      end
    end
  end
end
