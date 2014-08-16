#!/usr/bin/env ruby
require "csv"

str = ""
File.open("users.html", "r") do |file|
  file.each_line do |line|
  	str += line
  end
end

headers = []
result = str.scan /<th>(?<heading>[\w\s\,"]+)<\/th>/i
result.each do |header|
  if header[0].include? ","
  	string = header[0].scan /[\w\s]*/i
  	string.each do |word|
  	  unless word.empty?
        headers << word.strip
      end
    end
  else
    headers << header[0].strip
  end
end

contents = []
content = str.scan /<td>(?<content>[[\w"\@\$\.\/,][\s:"\-\+_]]*)<\/td>/i
content.each do |field|
  if field[0].include? ","
    string = field[0].scan /[\w\s\@\.\$\/_]*/i
    string.each do |word|
      unless word.empty?
        contents << word.strip
      end
    end
  else
    contents << field[0].strip
  end
end
contents = contents.each_slice(5).to_a

CSV.open("users.csv","w") do |data|
  data << headers
  contents.each do |content|
    data << content
  end
end

file_name = "users.csv"
header = CSV.read(file_name,"r")
class_str = '#!\usr\bin\env ruby'
