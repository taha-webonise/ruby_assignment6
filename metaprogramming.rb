#!/usr/bin/env ruby
require 'csv'
require 'active_support/core_ext/string'
require 'mongo'

binding = IRB.conf[:MAIN_CONTEXT].workspace.binding

#print "Please enter csv file name: "
#file_name = $stdin.gets.chomp
file_name = "users.csv"
contents = CSV.read(file_name, "r")
header = contents.shift
header_s = []
header.each do |h|
  header_s.push(h.downcase.tr(" ", "_"))
end

def create(class_name, *args)
  instance = Class.new do
    args.each do |arg|
      attr_accessor arg
    end
    define_method(:save) do |collection|
      document = Hash[self.instance_variables.collect {|name| [name, self.instance_variable_get(name)]}]
      #exists = collection.find_one("key"=> "value")
      #if exists.nil?
        collection.insert(document)
      #else
      #  exists.update(document)
      #end
    end
  end
  Object.const_set class_name, instance
end

class_name = file_name.split(".")[0].capitalize.singularize
create(class_name, *header_s)

obj = class_name.downcase
mongo_client = Mongo::MongoClient.new("localhost", 27017)
db = mongo_client.db("test")
collection = db.collection(class_name)
contents.each_with_index do |content, index|
  eval("#{obj}#{index+1} = #{class_name}.new", binding)
  header_s.zip(content).each do |var_name, value|
    eval("#{obj}#{index+1}.#{var_name} = #{value.inspect}", binding)
  end
  eval("#{obj}#{index+1}.save(collection)", binding)
end