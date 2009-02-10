# -*- coding: utf-8 -*-
module Filetter
  class Observer
    include Singleton

    def self.add_hook(*args, &block)
      instance.add_hook(*args, &block)
    end

    def self.run(options = {})
      options.each do |k, v|
        instance.__send__("#{k.to_s}=".to_sym, v) if instance.respond_to?(k)
      end
      instance.run
    end

    attr_accessor :pattern, :interval, :debug

    def initialize
      @pattern = './**/*'
      @interval = 1
      @work = true
      @initialized = false
      @file_infos = {}
      @hooks = {}
    end

    def run
      @observe_thread = Thread.new do
        while @work
          begin
            check_exists()
            check_modifies()
          rescue => e
            handle_error(e)
          ensure
            @initialized = true
            sleep @interval
          end
        end
      end

      @input_thread = Thread.new do
        while @work && line = Readline.readline('> ', true)
          begin
            eval(line) unless line.empty?
          rescue => e
            handle_error(e)
          end
        end
      end

      @observe_thread.join
      @input_thread.join
    end

    def exit
      @work = false
    end

    def add_hook(*args, &block)
      args.each do |arg|
        @hooks[arg] ||= []
        @hooks[arg] << block
      end
    end

    private

    def check_exists()
      real_files = Pathname.glob(@pattern).map{|i|i.realpath}
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

      if @initialized
        call_hooks(:created, created_files) unless created_files.empty?
        call_hooks(:deleted, deleted_files) unless deleted_files.empty?
      end
    end

    def check_modifies
      @file_infos.values.each{|i| i.check_modified}
      modifies = @file_infos.values.select{|i| !i.changes.empty?}
      call_hooks(:modified, modifies.map{|i| i.pathname}) unless modifies.empty?
    end

    def call_hooks(name, pathnames = [])
      return unless @hooks.has_key? name
      @hooks[name].each do |i|
        i.call(pathnames.map{|i|i.to_s})
      end
    end

    def handle_error(e)
      if debug
        puts "Error: #{e}"
        puts e.backtrace.join("\n")
      end
      call_hooks(:error)
    end
  end
end

