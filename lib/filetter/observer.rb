# -*- coding: utf-8 -*-
module Filetter
  class Observer
    include Singleton

    # deplecated
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
      @file_infos = {}
      @hooks = {}
    end

    def run
      collect_files

      @observe_thread = Thread.new do
        while @work
          begin
            check_files
          rescue => e
            handle_error(e)
          ensure
            sleep @interval
          end
        end
      end

      @input_thread = Thread.new do
        Readline.completion_proc = lambda {|input|
          self.methods.map{|i|i.to_s}.grep(/^#{Regexp.quote(input)}/)
        }
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

    def shutdown
      puts '...'
      @work = false
    end

    def add_hook(*args, &block)
      unless args.empty?
        args.each do |arg|
          @hooks[arg] ||= []
          @hooks[arg] << block
        end
      else
        @hooks[:any] ||= []
        @hooks[:any] << block
      end
    end

    private

    def collect_files
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
        @hooks[name].each{|i| i.call(pathnames.map{|i| i.to_s}) }
      end
      if @hooks.has_key?(:any)
        @hooks[:any].each{|i| i.call(pathnames.map{|i| i.to_s }, name) }
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

