# -*- coding: utf-8 -*-
module Filetter
  add_hook :modified do |files, event|
    puts "#{event}: #{files.inspect}"
  end

  add_hook :created do |files, event|
    puts "#{event}: #{files.inspect}"
  end

  add_hook :deleted do |files, event|
    puts "#{event}: #{files.inspect}"
  end
end
