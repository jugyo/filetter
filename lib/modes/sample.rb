# -*- coding: utf-8 -*-
module Filetter
  add_hook :modified do |files, event|
    print "#{event}: "
    p files
  end

  add_hook :created do |files, event|
    print "#{event}: "
    p files
  end

  add_hook :deleted do |files, event|
    print "#{event}: "
    p files
  end
end
