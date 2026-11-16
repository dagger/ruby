require "socket"

def varint(bytes, at)
  value = shift = 0
  loop do
    byte = bytes.getbyte(at)
    at += 1
    value |= (byte & 0x7f) << shift
    shift += 7
    return [value, at] if byte < 0x80
  end
end

# Protobuf fields by number; nested messages stay raw until decoded in turn.
# The numbers read below follow opentelemetry/proto/trace/v1/trace.proto.
def fields(bytes)
  out = Hash.new { |hash, key| hash[key] = [] }
  at = 0
  while at < bytes.bytesize
    key, at = varint(bytes, at)
    case key & 7
    when 0 then value, at = varint(bytes, at)
    when 1 then value, at = bytes.byteslice(at, 8), at + 8
    when 2
      size, at = varint(bytes, at)
      value, at = bytes.byteslice(at, size), at + size
    end
    out[key >> 3] << value
  end
  out
end

spans = []
server = TCPServer.new(4318)
loop do
  client = server.accept
  request = client.gets.to_s
  headers = {}
  while (line = client.gets) && line != "\r\n"
    name, value = line.split(":", 2)
    headers[name.downcase] = value.to_s.strip
  end
  body = client.read(headers["content-length"].to_i).to_s
  if request.start_with?("POST /v1/traces ")
    fields(body)[1].flat_map { |r| fields(r)[2] }.flat_map { |s| fields(s)[2] }.each do |raw|
      span = fields(raw)
      attrs = span[9].to_h { |kv| [fields(kv)[1][0], fields(fields(kv)[2][0])[1][0]] }
      spans << "#{span[5][0]} #{attrs["test.case.result.status"] || attrs["test.suite.run.status"]}"
    end
  end
  reply = spans.join("\n")
  client.write("HTTP/1.1 200 OK\r\nContent-Length: #{reply.bytesize}\r\nConnection: close\r\n\r\n#{reply}")
  client.close
end
