require 'socket'

server = TCPServer.new('localhost', 25)
puts("Server started...\n")

loop do
    s = server.accept
    puts s.recv 1024
    s.puts("Ok")
    s.close
end
