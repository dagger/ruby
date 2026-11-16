require "socket"
server = TCPServer.new(8080)
loop do
  client = server.accept
  request = client.gets.to_s
  headers = {}
  while (line = client.gets) && line != "\r\n"
    name, value = line.split(":", 2)
    headers[name.downcase] = value.to_s.strip
  end
  body = client.read(headers["content-length"].to_i).to_s
  ok = request.start_with?("POST /api/v1/gems ") && headers["authorization"] == "dummy-key" && !body.empty?
  # Echoing the rejected key proves the caller's output redacts it.
  reply = ok ? "Successfully registered gem" : "Rejected key #{headers["authorization"]}"
  client.write("HTTP/1.1 #{ok ? "200 OK" : "401 Unauthorized"}\r\nContent-Length: #{reply.bytesize}\r\nConnection: close\r\n\r\n#{reply}")
  client.close
end
