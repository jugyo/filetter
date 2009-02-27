# -*- coding: utf-8 -*-

require 'pathname'
require 'readline'
require 'singleton'

module Filetter
  class Observer
    include Singleton

    # deplecated
    def self.add_hook(*args, &block)
      instance.add_hook(*args, &block)
    end

    def self.run(options = {})
      instance.run(options)
    end

    attr_accessor :patterns, :interval, :debug, :prompt

    def initialize
      @patterns = './**/*'
      @interval = 1
      @work = true
      @file_infos = {}
      @hooks = {}
      @prompt = '> '
    end

    def run(options = {})
      options.each do |k, v|
        self.__send__("#{k.to_s}=".to_sym, v) if self.respond_to?(k)
      end

      puts "=> initializing..."
      collect_files

      @input_thread = Thread.new do
        Readline.completion_proc = lambda {|input|
          self.methods.map{|i|i.to_s}.grep(/^#{Regexp.quote(input)}/)
        }
        puts '=> Enter "exit" to exit.'
        while @work && line = Readline.readline(@prompt, true)
          begin
            eval(line) unless line.empty?
          rescue => e
            handle_error(e)
          end
        end
      end

      sleep @interval

      @observe_thread = Thread.new do
        while @work
          begin
            puts 'checking files...' if debug
            check_files
          rescue => e
            handle_error(e)
          ensure
            sleep @interval
          end
        end
      end

      @observe_thread.join
      @input_thread.join
    end

    def exit
      puts 'exiting...'
      @work = false
    end

    def add_hook(*args, &block)
      unless args.empty?
        args.each do |arg|
          hook_name = normalize_as_hook_name(arg)
          @hooks[hook_name] ||= []
          @hooks[hook_name] << block
        end
      else
        @hooks[:any] ||= []
        @hooks[:any] << block
      end
    end

    private

    def collect_files
      real_files = Pathname.glob(@patterns).map do |i|
        if debug
          print "\e[1K\e[0G#{i.basename.to_s}"
          $stdout.flush
        end
        i.realpath
      end

      if debug
        print "\e[1K\e[0G"
        $stdout.flush
      end

      current_files = @file_infos.keys
      created_files = real_files - current_files
      deleted_files = current_files - real_files

      @file_infos.delete_if do |k, v|
        deleted_files.include?(k)
      end

      created_files.map!{|i|i.realpath}
      created_files.each do |pathname|
        @file_infos[pathname] = FileInfo.new(pathname)
      end

      [created_files, deleted_files]
    end

    def check_files
      check_exists
      check_modifies
    end

    def check_exists
      created_files, deleted_files = collect_files
      call_hooks(:created, created_files) unless created_files.empty?
      call_hooks(:deleted, deleted_files) unless deleted_files.empty?
    end

    def check_modifies
      @file_infos.values.each{|i| i.check_modified}
      modifies = @file_infos.values.select{|i| !i.changes.empty?}
      call_hooks(:modified, modifies.map{|i| i.pathname}) unless modifies.empty?
    end

    def call_hooks(name, pathnames = [])
      if @hooks.has_key?(name) && !pathnames.empty?
        @hooks[name].each do |i|
          begin
            i.call(pathnames.map{|i| i.to_s}, name)
          rescue => e
            handle_error(e)
          end
        end
      end
      if @hooks.has_key?(:any)
        @hooks[:any].each do |i|
          begin
            i.call(pathnames.map{|i| i.to_s }, name)
          rescue => e
            handle_error(e)
          end
        end
      end
    end

    def handle_error(e)
      if debug
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
      end
    end

    def normalize_as_hook_name(name)
      case name.to_s
      when /^created?$/
        :created
      when /^(modif(y|ied)|updated?)$/
        :modified
      when /(deleted?|removed?)/
        :deleted
      end
    end
  end
end
