# -*- coding: utf-8 -*-

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
    def run(options = {})
      patterns = []
      interval = 2
      debug = false
      mode = nil
      load_file = '.filetter'
      work_dir = nil
      help = nil
      list = false

      OptionParser.new do |opt|
        opt.version = VERSION
        opt.program_name = self.to_s
        opt.on('-m', '--mode=mode', 'Run mode'                                  ) {|v| mode = v       }
        opt.on('-f', '--loadfile=file', 'File to load'                          ) {|v| load_file = v  }
        opt.on('-c', '--cd=directory', 'cd to directory'                        ) {|v| work_dir = v   }
        opt.on('-p', '--pattern=pattern', 'Pattern of target files'             ) {|v| patterns << v  }
        opt.on('-i', '--interval=interval', 'Interval of check files', Integer  ) {|v| interval = v   }
        opt.on('-d', '--debug', 'Enable debug mode'                             ) {|v| debug = true   }
        opt.on('-l', '--list', 'List up available modes'                        ) {|v| list = true    }
        opt.parse!(ARGV)
        help = opt.help
      end

      if work_dir
        Dir.chdir(work_dir)
        puts "=> cd to #{work_dir}"
      end

      patterns << './**/*' if patterns.empty?

      begin
        if mode.nil? && !File.exist?(load_file)
          if list
            puts Dir[File.dirname(__FILE__) + '/modes/*.rb'].map{|f|File.basename(f).gsub(/\.rb$/, '')}
            exit
          else
            puts help
            exit!
          end
        else
          if File.exist?(load_file)
            puts "=> load \"#{load_file}\""
            load load_file
          end
          if mode
            puts "=> Run as \"#{mode}\" mode"
            require "modes/#{mode}"
          end
        end
      rescue LoadError => e
        puts e
        raise if debug
        exit!
      rescue => e
        puts e
        raise if debug
        exit!
      end

      Observer.run({:patterns => patterns, :interval => interval, :debug => debug}.merge(options))
    end

    def add_hook(*args, &block)
      Observer.instance.add_hook(*args, &block)
    end
  end
end
