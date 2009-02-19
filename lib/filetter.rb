# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__) + '/modes')

require 'rubygems'
require 'configatron'
def config; configatron; end

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
      config_file = '.filetter'
      mode = nil
      load_file = nil

      OptionParser.new do |opt|
        opt.version = VERSION
        opt.program_name = self.to_s
        opt.on('-c', '--config=file', 'Configuration file'            ) {|v| config_file = v  }
        opt.on('-m', '--mode=mode', 'Run mode'                        ) {|v| mode = v         }
        opt.on('-f', '--file=file', 'File to load'                    ) {|v| load_file = v    }
        opt.on('-p', '--pattern=pattern', 'Pattern of target files'   ) {|v| pattern = v      }
        opt.on('-i', '--interval=interval', 'Interval of check files' ) {|v| interval = v     }
        opt.on('-d', '--debug', 'Enable debug mode'                   ) {|v| debug = true     }
        opt.parse!(ARGV)
      end

      begin
        unless mode || load_file
          require 'sample'
        else
          require mode if mode
          load load_file if load_file && File.exist?(load_file)
        end
        load config_file if config_file && File.exist?(config_file)
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
