#!/usr/bin/env ruby
require 'csv'
require 'active_support/core_ext/string'

binding = IRB.conf[:MAIN_CONTEXT].workspace.binding

# file_name = "users.csv"
print "Please enter csv file name: "
file_name = $stdin.gets.chomp
contents = CSV.read(file_name, "r")
header = contents.shift
header_s = []
header.each do |h|
  header_s.push(h.downcase.tr(" ", "_"))
end

def create(class_name, *vars)
  instance = Class.new do
    vars.each do |var|
    	attr_accessor var.intern
    end
  end
  Object.const_set class_name, instance
end

class_name = file_name.split(".")[0].capitalize.singularize
create(class_name, *header_s)

obj_array = []
obj = class_name.downcase
contents.each_with_index do |content, index|
  eval("#{obj}#{index+1} = #{class_name}.new", binding)
  header_s.zip(content).each do |var_name, value|
    eval("#{obj}#{index+1}.#{var_name} = #{value.inspect}", binding)
  end
  obj_array.push(eval("#{obj}#{index+1}", binding))
end