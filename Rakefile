# -*- coding: utf-8 -*-
$:.unshift File.dirname(__FILE__) + '/lib/'
require 'filetter'
require 'spec/rake/spectask'

desc 'run all specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-c']
end

desc 'Generate gemspec'
task :gemspec do |t|
  open('filetter.gemspec', "wb" ) do |file|
    file << <<-EOS
Gem::Specification.new do |s|
  s.name = 'filetter'
  s.version = '#{Filetter::VERSION}'
  s.summary = "Filetter is a pluggable tool for file system."
  s.description = "Filetter is a pluggable tool for file system."
  s.files = %w( #{Dir['lib/**/*.rb'].join(' ')}
                #{Dir['spec/**/*.rb'].join(' ')}
                README.rdoc
                History.txt
                Rakefile )
  s.executables = ["filetter"]
  s.add_dependency("configatron", ">= 2.2.2")
  s.add_dependency("rubytter", ">= 0.4.5")
  s.add_dependency("rflickr", ">= 2006.02.01")
  s.add_dependency("highline", ">= 1.5.0")
  s.author = 'jugyo'
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/filetter'
  s.rubyforge_project = 'filetter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
    EOS
  end
  puts "Generate gemspec"
end

desc 'Generate gem'
task :gem => :gemspec do |t|
  system 'gem', 'build', 'filetter.gemspec'
end
