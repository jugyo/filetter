# -*- coding: utf-8 -*-
module Filetter
  add_hook :modified do |files|
    print 'modified: '
    p files
  end

  add_hook :created do |files|
    print 'created: '
    p files
  end

  add_hook :deleted do |files|
    print 'deleted: '
    p files
  end
end
