require 'sinatra'
require 'pinterest-api'

client = Pinterest::Client.new(ENV['PINTEREST_TEST'])

# sets public folder to public dir
set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
	data = client.me.data
	# p data
	p client
	p '=============='
	p data.first_name
	p '=============='
	erb :index, :locals => {:data => data}
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