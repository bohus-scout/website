require 'socket'

server = TCPServer.new('localhost', 25)
puts("Server started...\n")

loop do
    s = server.accept
    while line = s.gets
        puts line
        if line.chomp == "."
            break
        end
    end
    s.puts("Ok")
    s.close
end
