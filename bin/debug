#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

$KCODE="u" unless Object.const_defined? :Encoding

self_file =
  if File.ftype(__FILE__) == 'link'
    File.readlink(__FILE__)
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/lib")

conf_file = '.filetter'

require 'filetter'
Filetter.run(conf_file, :debug => true)

# Startup scripts for development
