require "socket"

def parse_request(request_line)
  http_method, path, params = request_line.split(/[? ]/)
  
  params = params.split("&").each_with_object({}) do |pair, hash|
    key, value = pair.split("=")
    hash[key] = value
  end
  [http_method, path, params]
end 

server = TCPServer.new("localhost", 3003)
loop do
  client = server.accept

  request_line = client.gets
  puts request_line

  http_method, path, params = parse_request(request_line)


  client.puts "HTTP/1.0 200 OK"
  client.puts "Content-Type: text/html"
  client.puts
  client.puts "<html>"
  client.puts "<body>"
  client.puts "<pre>"
  client.puts "This is the request line: #{request_line}"
  client.puts "This is the http method: #{http_method}"
  client.puts "This is the path: #{path}"
  client.puts "These are the parameters: #{params}"
  client.puts "</pre>"
  
  client.puts "<h1>Rolls!</h1>"
  rolls = params["rolls"].to_i
  sides = params["sides"].to_i

  rolls.times do
    client.puts "<p>", rand(sides) + 1, "</p>"
  end
  client.puts "</body>"
  client.puts "</html>"

  client.close
end

