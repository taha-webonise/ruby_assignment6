#!/usr/bin/env ruby
require "csv"

class HTMLToCSV

  def read_html
    @str = ""
    @file_name = "users.html"
    File.open(@file_name, "r") do |file|
      file.each_line do |line|
  	    @str += line
      end
    end
  end

  def extract_header
    @headers = []
    result = @str.scan /<th>(?<heading>[\w\s\,"]+)<\/th>/i
    result.each do |header|
      if header[0].include? ","
  	    string = header[0].scan /[\w\s]*/i
  	    string.each do |word|
  	      unless word.empty?
            @headers << word.strip
          end
        end
      else
        @headers << header[0].strip
      end
    end
  end

  def extract_contents
    @contents = []
    content = @str.scan /<td>(?<content>[[\w"\@\$\.\/,][\s:"\-\+_]]*)<\/td>/i
    content.each do |field|
      if field[0].include? ","
        string = field[0].scan /[\w\s\@\.\$\/_]*/i
        string.each do |word|
          unless word.empty?
            @contents << word.strip
          end
        end
      else
        @contents << field[0].strip
      end
    end
  end

  def create_csv
    @contents = @contents.each_slice(5).to_a
    CSV.open("#{@file_name.split(".")[0]}.csv","w") do |data|
      data << @headers
      @contents.each do |content|
        data << content
      end
    end
  end

  def self.convert
    parser = self.new
    parser.read_html
    parser.extract_header
    parser.extract_contents
    parser.create_csv
  end
end

HTMLToCSV.convert