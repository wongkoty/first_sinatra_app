require 'sinatra'
require 'pinterest-api'
require 'httparty'
require 'pp'

client = Pinterest::Client.new(ENV['PINTEREST_TEST'])

# sets public folder to public dir
set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
	url = "https://api.pinterest.com/v1/me/boards/?access_token=" + ENV['PINTEREST_TEST']
	# puts url
	response = HTTParty.get(url)
	test_data = response.parsed_response

	pp test_data["data"][0]["url"]

	p "=================="

	pp client.get_boards.class
	# pp client.get_boards.keys
	# p test_data.data[0]

	# url = "https://api.pinterest.com/v1/me/pins/?access_token=" + ENV['PINTEREST_TEST']
	# puts url
	# response = HTTParty.get(url)
	# p response.parsed_response

	data = client.me.data
	# p client.get_pins
	client_boards = client.get_boards.data
	client_pins = client.get_pins.data
	# p data
	# p client_boards
	p '=============='
	# p data.first_name
	p '=============='
	erb :index, :locals => {:data => data, :client_boards => client_boards, :client_pins => client_pins}
end

get '/poke' do
	erb :show
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  "Hello #{params['name']}!"
end

set(:probability) { |value| condition { rand <= value } }

get '/win_a_car', :probability => 0.1 do
  "You won!"
end

get '/win_a_car' do
  "Sorry, you lost."
end