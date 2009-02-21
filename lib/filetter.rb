# -*- coding: utf-8 -*-
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/modes'))

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
      mode = nil
      load_path = nil
      load_file = '.filetter'
      work_dir = nil

      OptionParser.new do |opt|
        opt.version = VERSION
        opt.program_name = self.to_s
        opt.on('-m', '--mode=mode', 'Run mode'                                  ) {|v| mode = v       }
        opt.on('-l', '--loadpath=path', 'Library load path'                     ) {|v| load_path = v  }
        opt.on('-f', '--loadfile=file', 'File to load'                          ) {|v| load_file = v  }
        opt.on('-c', '--cd=directory', 'cd to directory'                        ) {|v| work_dir = v   }
        opt.on('-p', '--pattern=pattern', 'Pattern of target files'             ) {|v| pattern = v    }
        opt.on('-i', '--interval=interval', 'Interval of check files', Integer  ) {|v| interval = v   }
        opt.on('-d', '--debug', 'Enable debug mode'                             ) {|v| debug = true   }
        opt.parse!(ARGV)
      end

      $:.unshift(File.expand_path(load_path)) if load_path

      if work_dir
        Dir.chdir(work_dir)
        puts "=> cd to #{work_dir}"
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
          if load_file && File.exist?(load_file)
            puts "=> load \"#{load_file}\""
            load load_file
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

      Observer.run(:pattern => pattern, :interval => interval, :debug => debug)
    end

    def add_hook(*args, &block)
      Observer.instance.add_hook(*args, &block)
    end
  end
end
