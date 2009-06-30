require 'net/http'
require 'uri'
require 'rexml/document'
require 'rubygems'
require 'sqlite3'
include REXML

class ItemPrice
	def initialize
		@url_base = "http://api.eve-central.com/api/marketstat?"
		@regionlimit = "10000002"
	end

	def namesToIDs(names)
		ids = Array.new
		names.each { |name|
			ids << nameToID(name)
		}
		return ids
	end

	def nameToID(sStr)
		die("Database not found") if !File.exists?('invTypes.db') 
		db = SQLite3::Database.new("invTypes.db")
		sql = "SELECT typeID FROM invTypes WHERE typeName LIKE '#{sStr}%' LIMIT 1"
		return db.get_first_value(sql)
	end

	def priceMatch(ids)
		typeIDs = ""
		ids.each { |id|
			typeIDs << "typeid=#{id}&"
		}
		typeIDs.chop!
		url = @url_base + typeIDs + "&regionlimit=#{@regionlimit}"
		
		src = Net::HTTP::get URI::parse(url)
		xmldoc = Document.new(src)
		XPath.each(xmldoc,'//sell/median') { |e|
			price = e.text
			price.gsub!(/(\d)(?=\d{3}+(?:\D|$))/, '\\1,')
			puts "#{price}"
		}
	end

	def die(msg)
		puts "\n#{msg}\n"
		exit
	end
end
