Gem::Specification.new do |s|
  s.name = 'filetter'
  s.version = '0.0.1'
  s.summary = "Filetter is a pluggable tool for file system."
  s.description = "Filetter is a pluggable tool for file system."
  s.files = %w( lib/filetter/file_info.rb lib/filetter/observer.rb lib/filetter/version.rb lib/filetter.rb lib/plugins/mozrepl.rb lib/plugins/sample.rb
                
                
                README.rdoc
                History.txt
                Rakefile )
  s.executables = ["filetter"]
  #s.add_dependency("rubytter", ">= 0")
  s.author = 'jugyo'
  s.email = 'jugyo.org@gmail.com'
  s.homepage = 'http://github.com/jugyo/filetter'
  s.rubyforge_project = 'filetter'
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.rdoc", "--exclude", "spec"]
  s.extra_rdoc_files = ["README.rdoc", "History.txt"]
end
