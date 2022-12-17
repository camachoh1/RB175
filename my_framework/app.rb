require_relative 'monroe'
require_relative 'advice'
require 'erb'

class App < Monroe

  def call(env)
    case env['REQUEST_PATH']
    when '/'
      status = '200'
      headers = {'Content Type' => 'text/plain'}
      response(status, headers) do 
        erb :index
      end
    when '/advice'
      piece_of_advice = Advice.new.generate
      status = '200'
      headers = {'Content Type' => 'text/plain'}
      response(status, headers) do
        erb :advice, message: piece_of_advice
      end
    else
      status = '404'
      headers = {"Content-Type" => 'text/plain', "Content-Length" => '60'}
      response(status, headers) do
        erb :not_found
      end
    end
  end
end