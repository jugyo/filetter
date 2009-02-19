# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$: << File.dirname(__FILE__) + '/modes'

require 'rubygems'
require 'configatron'

require 'filetter/version'
require 'filetter/file_info'
require 'filetter/observer'
require 'optparse'

Thread.abort_on_exception = true

module Filetter
  class << self
    def run
      pattern = './**/*'
      interval = 1
      debug = false

      OptionParser.new do |opt|
        opt.on('-m mode', 'run mode') {|v| require v } # use mode
        opt.on('-f file', 'file to load') {|v| load v } # load user file
        opt.on('-p pattern', 'target files pattern') {|v| pattern = v }
        opt.on('-i interval', 'check files interval') {|v| interval = v }
        opt.on('-d', 'enable debug mode') {|v| debug = true}
        begin
          opt.parse!(ARGV)
        rescue LoadError => e
          puts e
          exit!
        end
      end

      Observer.run(:pattern => pattern, :interval => interval, :debug => debug)
    end

    def add_hook(*args, &block)
      Observer.instance.add_hook(*args, &block)
    end
  end
end
