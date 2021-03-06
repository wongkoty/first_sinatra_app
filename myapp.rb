require 'sinatra'
require 'pinterest-api'
require 'httparty'
require 'pp'
require 'slim'
require 'omniauth-pinterest'

puts ENV['PINTEREST_APP_ID']
puts ENV['PINTEREST_SECRET']

enable :sessions

use OmniAuth::Builder do
	provider :pinterest, ENV['PINTEREST_APP_ID'], ENV['PINTEREST_SECRET']
end

helpers do
  def admin?
    session[:admin]
  end
end

get '/public' do
  "This is the public page - everybody is welcome!"
end

get '/private' do
  halt(401,'Not Authorized') unless admin?
  "This is the private page - members only"
end

get '/login' do
	redirect to("/auth/pinterest")
end

get '/logout' do
  session[:admin] = nil
  session[:id] = nil
  "You are now logged out"
end

get '/auth/pinterest/callback' do
 	session[:admin] = true
  session[:id] = env['omniauth.auth']['info']['id']
  # pp session
  client = Pinterest::Client.new(session[:id])
  pp env['omniauth.auth']
  pp client
  "<h1>Hi #{session[:username]}!</h1>"

  redirect to("/")
end

get '/auth/failure' do
  params[:message]
end

client = Pinterest::Client.new(ENV['PINTEREST_TEST'])

# sets public folder to public dir
set :public_folder, File.dirname(__FILE__) + '/public'

get '/' do
	url = "https://api.pinterest.com/v1/me/boards/?access_token=" + ENV['PINTEREST_TEST']
	# puts url
	response = HTTParty.get(url)
	test_data = response.parsed_response

	pp session
	pp session[:username]
	p request.env['omniauth.auth']

	# pp test_data["data"][0]["url"]

	p "=================="

	# pp client.get_boards.class
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
	pp client_boards
	p '=============='
	# p data.first_name
	p '=============='
	slim :index, :locals => {:data => data, :client_boards => client_boards, :client_pins => client_pins}
end

get '/board/:id' do
	puts "show route"
	# puts params[:id]
	url = "https://api.pinterest.com/v1/boards/" + params[:id] + "/?access_token=" + ENV['PINTEREST_TEST']
	puts url
	response = HTTParty.get(url)
	test_data = response.parsed_response["data"]

	pp test_data

	slim :show, :locals => {:data => test_data}
	
end

get '/pins' do
	puts "pins index"
	client_pins = client.get_pins.data
	pp client_pins

	erb :"pins/index", :locals => {:client_pins => client_pins}

end

get '/pin/:id' do
	puts "show pin route"
	# puts params[:id]
	url = "https://api.pinterest.com/v1/pins/" + params[:id] + "/?access_token=" + ENV['PINTEREST_TEST']
	puts url
	response = HTTParty.get(url)
	test_data = response.parsed_response["data"]

	pp test_data

	erb :"pins/show", :locals => {:data => test_data}
end

get '/pin/:id/edit' do
	puts "edit pin route"
	# puts params[:id]
	url = "https://api.pinterest.com/v1/pins/" + params[:id] + "/?access_token=" + ENV['PINTEREST_TEST'] + "&scope=write_public"
	puts url
	response = HTTParty.get(url)
	test_data = response.parsed_response["data"]
	pp test_data

	erb :"pins/edit", :locals => {:data => test_data}

end

patch '/pin/:id' do 
	puts "patch pin route"
	puts params["note"]
	url = "https://api.pinterest.com/v1/pins/" + params[:id] +  "/?access_token=" + ENV['PINTEREST_TEST'] + "&note=" + params["note"]
	puts url
	response = HTTParty.patch(url)
	# test_data = response.parsed_response["data"]

	redirect to ("pin/" + params[:id])

end

delete '/pin/:id' do
	puts "deleting this pin"
	puts params[:id]

	url = "https://api.pinterest.com/v1/pins/" + params[:id] + "/?access_token=" + ENV['PINTEREST_TEST']
	puts url
	response = HTTParty.delete(url)
	# test_data = response.parsed_response["data"]

	redirect to ("pins")

end


# get '/poke' do
# 	erb :show
# end

# get '/hello/:name' do
#   # matches "GET /hello/foo" and "GET /hello/bar"
#   # params['name'] is 'foo' or 'bar'
#   "Hello #{params['name']}!"
# end

set(:probability) { |value| condition { rand <= value } }

get '/win_a_car', :probability => 0.1 do
  "You won!"
end

get '/win_a_car' do
  "Sorry, you lost."
end