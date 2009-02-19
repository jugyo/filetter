# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/modes')

require 'optparse'
require 'rubygems'
require 'configatron'
def config; configatron; end

require 'filetter/version'
require 'filetter/file_info'
require 'filetter/observer'

Thread.abort_on_exception = true

module Filetter
  class << self
    def run
      pattern = './**/*'
      interval = 1
      debug = false
      config_file = '.filetter'
      mode = nil
      load_file = nil

      OptionParser.new do |opt|
        opt.version = VERSION
        opt.program_name = self.to_s
        opt.on('-m', '--mode=mode', 'Run mode'                        ) {|v| mode = v         }
        opt.on('-f', '--load=file', 'File to load'                    ) {|v| load_file = v    }
        opt.on('-p', '--pattern=pattern', 'Pattern of target files'   ) {|v| pattern = v      }
        opt.on('-i', '--interval=interval', 'Interval of check files' ) {|v| interval = v     }
        opt.on('-d', '--debug', 'Enable debug mode'                   ) {|v| debug = true     }
        opt.parse!(ARGV)
      end

      begin
        unless mode || load_file
          puts '=> Run as "sample" mode'
          require 'sample'
        else
          if mode
            puts "=> Run as \"#{mode}\" mode"
            require mode
          end
          if load_file
            puts "=> load \"#{load_file}\""
            load load_file
          end
        end
      rescue LoadError => e
        puts e
        exit!
      end

      Observer.run(:pattern => pattern, :interval => interval, :debug => debug)
    end

    def add_hook(*args, &block)
      Observer.instance.add_hook(*args, &block)
    end
  end
end
