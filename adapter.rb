require 'thin'

class SimpleAdapter
  def call(env)
    body = ["hello!"]
    [
      200,
      { 'Content-Type' => 'text/plain' },
      body
    ]
  end
end

Thin::Server.start('0.0.0.0', 3000) do
  use Rack::CommonLogger
  map '/test' do
    run SimpleAdapter.new
  end
  map '/files' do
    run Rack::File.new('.')
  end
end
