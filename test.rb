require 'socket'
a = TCPSocket.new('127.0.0.1', 3000) # could replace 127.0.0.1 with your "real" IP if desired.
a.write "GETTT 1"
puts "got back:" + a.recv(1024)
# a.close