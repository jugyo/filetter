# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

module Filetter
  class Observer
    describe Observer do
      before do
        @observer = Observer.instance
      end

      it 'should normalize hook name' do
        [:created, :create].each do |name|
          @observer.instance_eval{ normalize_as_hook_name(name).should == :created }
        end
        [:update, :updated, :modify, :modified].each do |name|
          @observer.instance_eval{ normalize_as_hook_name(name).should == :modified }
        end
        [:delete, :deleted, :remove, :removed].each do |name|
          @observer.instance_eval{ normalize_as_hook_name(name).should == :deleted }
        end
        [:createx, :creat, :modifi, :modifie, :modifeed, :updat, :updatedd].each do |name|
          @observer.instance_eval{ normalize_as_hook_name(name).should == nil }
        end
      end
    end
  end
end
