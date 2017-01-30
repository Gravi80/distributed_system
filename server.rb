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
      puts("Request received at server running on port #{@port}")
      request = connection.recv(1024)
      connection.write("#{process_request(request.split)}\n")
      connection.close
    }
  end

  private
  def valid_address?(address)
    last_index >= address
  end

  def process_request(request_params)
    method = request_params[0]
    address = request_params[1].to_i
    if method =~ /(PUT|GET)$/ and valid_address?(address)
      if method == 'GET'
        process_get(address)
      else
        process_put(address, request_params[2].to_i)
      end
    else
      "Invalid Request: Only GET and PUT are accepted and address should be between 0 and #{last_index}\n"
    end
  end


  def process_get(address)
    puts("GET request to read value at address #{address}")
    @dsm.read(address)
  end

  def process_put(address, new_value)
    puts("PUT request to update value of address #{address} to #{new_value}")
    @dsm.write(address, new_value)
    "Successfully updated the value of address #{address} with #{new_value}"
  end

  def last_index
    CONFIG['raw_data'].length - 1
  end
end