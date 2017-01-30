require_relative 'config'
require_relative 'dsm'
require 'socket'

class Server
  def initialize port, dsm
    @dsm = dsm
    @port = port
    @tcp_server = TCPServer.new(CONFIG['host'], @port)
  end

  def accept_requests
    loop {
      connection = @tcp_server.accept
      puts("Request received on server running on port #{@port}")
      request = connection.recv(1024)
      if request =~ /(PUT\s\d\s\d|GET\s\d)/
        request_params = request.split
        if request_params[0] == 'GET'
          connection.write("#{@dsm.read(request_params[1].to_i)}\n")
        else
          @dsm.write(request_params[1].to_i, request_params[2].to_i)
        end
      else
        connection.write('Invalid Request')
      end
      connection.close
    }
  end

  private
  def forward_request_to(port, request)
    socket = TCPSocket.new(CONFIG['host'], port) # could replace 127.0.0.1 with your "real" IP if desired.
    socket.write(request)
    puts "got back: #{socket.recv(1024)}"
    socket.close
  end
end