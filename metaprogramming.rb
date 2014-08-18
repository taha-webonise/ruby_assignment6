#!/usr/bin/env ruby
require 'csv'
require 'active_support/core_ext/string'
require 'mongo'

binding = IRB.conf[:MAIN_CONTEXT].workspace.binding

print "Please enter csv file name: "
file_name = $stdin.gets.chomp
contents = CSV.read(file_name, "r")
header = contents.shift
header_s = []
header.each do |h|
  header_s.push(h.downcase.tr(" ", "_"))
end

def spawn_class(class_name, *args)
  instance = Class.new do
    args.each do |arguement|
      attr_accessor arguement
    end
    
    print "Please enter the primary key of csv : "
    p_key = $stdin.gets.chomp
    
    define_method(:save_object) do |collection|  
      document = Hash[self.instance_variables.collect {|name| [name, self.instance_variable_get(name)]}]
      document_exists = collection.find_one("@#{p_key}"=> self.instance_variable_get("@#{p_key}"))
      
      if document_exists.nil?
        collection.insert(document)
      else
        document_exists.update(document)
        collection.save document_exists
      end
    end
  end
  Object.const_set class_name, instance
end

def create_collection(class_name)
  mongo_client = Mongo::MongoClient.new("localhost", 27017)

  if mongo_client.database_names.include? "test"
    mongo_client.drop_database "test"
  end
  db = mongo_client.db("test")
  
  if db.collection_names.include? class_name
    db.drop_collection class_name
  end
  collection = db.collection(class_name)
end

class_name = file_name.split(".")[0].capitalize.singularize
spawn_class(class_name, *header_s)
obj = class_name.downcase
collection = create_collection(class_name)

contents.each_with_index do |content, index|
  eval("#{obj}#{index+1} = #{class_name}.new", binding)

  header_s.zip(content).each do |var_name, value|
    eval("#{obj}#{index+1}.#{var_name} = #{value.inspect}", binding)
  end

  eval("#{obj}#{index+1}.save_object(collection)", binding)
end