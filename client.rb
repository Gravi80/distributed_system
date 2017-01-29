require 'socket'
a = TCPSocket.new('127.0.0.1', 4000) # could replace 127.0.0.1 with your "real" IP if desired.
a.write "PUT 7 7"
puts "got back:" + a.recv(1024)
a.close