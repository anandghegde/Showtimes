# Using Nokogiri and xpath to fetch theatres in your city
# Illegally scrapes data off of the Google showtimes page :P

#Usage -
# ruby showtimes.rb Bangalore

require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'pp'

INPUT=ARGV[0]

class MovieShowtimes
	attr_reader=[:city]

	def initialize(city)
		@city=city
	end

	def fetch_content(city)
		url="http://google.com/movies?near=#{city}"
		doc=Nokogiri::HTML(open(url))
		return doc
	end


	def get_timings(movie)
		return_string=""
		return_string=movie.xpath('.//div[@class="times"]').first.content
		return_string.gsub!("&nbsp", "")
		return return_string
	end

	def get_movies(theater)
		movies=[]
		theater.xpath('.//div[@class="show_left"]/div[@class="movie"]').each do |movie|
			movieHash=Hash.new()
			movie_name=movie.xpath('.//div[@class="name"]').first.content
			movieHash[movie_name]=get_timings(movie)
			movies.push(movieHash)
		end
		theater.xpath('.//div[@class="show_right"]/div[@class="movie"]').each do |movie|
			movieHash=Hash.new()
			movie_name=movie.xpath('.//div[@class="name"]').first.content
			movieHash[movie_name]=get_timings(movie)
			movies.push(movieHash)
		end
		return movies
	end		


	def get_theatres()
		doc=fetch_content(@city)
		i=1
		result=Hash.new()
		doc.xpath('//div[@class="theater"]').each do |theater|
			inner=Hash.new()
			inner[:name]=theater.xpath('.//h2').first.content
			inner[:movies]=[]
			inner[:movies]=get_movies(theater)
			result["theater#{i}"]=inner
			i=i+1
		end
		pp result
	end
end

example = MovieShowtimes.new(INPUT)
example.get_theatres()
