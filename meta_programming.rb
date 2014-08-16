#!/usr/bin/env ruby
require 'csv'
require 'active_support/core_ext/string'

file_name = "users.csv"
header = CSV.read(file_name,"r")[0]
content = CSV.read(file_name, "r")
content.shift
header_s = []
header.each do |h|
  header_s.push(h.downcase.tr(" ", "_"))
end

class NewClass
  def self.dynamic_create(class_name, *cols)
    instance = Class.new do
      cols.each do |col|
      	attr_accessor col.intern
      end
    end
    Object.const_set class_name, instance
  end
end

class_name = file_name.split(".")[0].capitalize.singularize
NewClass.dynamic_create(class_name, *header_s)

obj_array = []

content.each_with_index do |name, index|
  eval("obj#{index} = #{class_name}.new")
  header_s.zip(content).each do |name, value|
    eval("obj#{index}.#{name} = #{value}")
  end
  obj_array.push(eval("obj#{index}"))
end