require 'socket'

host = 'localhost'
port = 25

server = TCPServer.new(host, port)
puts("Server started. Listening at #{port}\n")

loop do
    s = server.accept

    while line = s.gets
        
        puts line
        msg = ""

        case line.chomp
        when "exit"
            break
        when "EHLO", "HELO"
            s.puts("Hello client!")
        when "DATA"
            s.puts "220 Ok"
            msg += s.gets while s.gets.chomp != "."

        end
        
    end
    s.puts("Ok")
    s.close
    puts("Conn closed from #{s}")
end
