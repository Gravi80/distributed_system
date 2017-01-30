require_relative 'address_mapper'

class Dsm

  def initialize(data, index_map)
    @data = data
    @index_map = index_map
  end

  def write(address, new_value)
    if locally_present?(address)
      puts "Address: #{address} is locally present"
      @index_map.each do |key, value|
        if value == address
          @data[key] = new_value
        end
      end
    else
      forward_request(address, "PUT #{address} #{new_value}\000")
    end
  end

  def read(address)
    if locally_present?(address)
      puts "Address: #{address} is locally present"
      @index_map.each do |key, value|
        return @data[key] if value == address
      end
    else
      socket = forward_request(address, "GET #{address}\000")
      socket.recv(1024)
    end
  end

  private
  def locally_present?(address)
    @index_map.values.include?(address)
  end

  def forward_request(address, request)
    process_number = AddressMapper.new.get_process_for(address)
    puts "Address: #{address} is present at server running on port #{CONFIG['first_process_port']+process_number}"
    puts "Forwarding request to server running on port #{CONFIG['first_process_port']+process_number}"
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port']+process_number)
    socket.write request
    socket
  end
end