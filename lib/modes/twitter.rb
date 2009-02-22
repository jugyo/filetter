# -*- coding: utf-8 -*-
require 'rubytter'

if config.twitter.login.empty? || config.twitter.password.empty?
  puts "Config not found! => [config.twitter.login, config.twitter.password]"
  exit!
end

module Filetter
  rubytter = Rubytter.new(config.twitter.login, config.twitter.password, :header => {
    'User-Agent' => "Filetter/#{VERSION} (http://wiki.github.com/jugyo/filetter)"
  })

  add_hook :create do |files, event|
    files.each do |file|
      file_name = File.basename(file)
      rubytter.update(file_name)
      puts "=> Post to twitter '#{file_name}'"
    end
  end
end
