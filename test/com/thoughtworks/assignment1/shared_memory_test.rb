require_relative '../../../../src/com/thoughtworks/assignment1/config'
require 'test/unit'
require 'test/unit/ui/console/testrunner'

class SharedMemoryTest < Test::Unit::TestCase

  def self.startup
    require_relative '../../../../src/com/thoughtworks/assignment1/start'
  end

  def self.shutdown
    system("kill -9 $(lsof -Pti @localhost:#{CONFIG['first_process_port']}-#{CONFIG['first_process_port']+CONFIG['process_count']} -sTCP:LISTEN)")
  end

  CONFIG['raw_data'].length.times do |address|
    (CONFIG['first_process_port']..(CONFIG['first_process_port']+CONFIG['process_count']-1)).to_a.each do |port|
      define_method("test_should_get_data_on_address_#{address}_through_process_port_#{port}") do
        socket = TCPSocket.new(CONFIG['host'], port)
        socket.write "GET #{address}"
        assert_equal(address, socket.recv(1024).to_i)
      end
    end
  end

  def test_should_return_error_when_invalid_request_method_is_passed
    socket = TCPSocket.new(CONFIG['host'], 3000)
    socket.write 'INVALID 4'
    last_index = CONFIG['raw_data'].length - 1
    assert_equal("Invalid Request: Only GET and PUT are accepted and address should be between 0 and #{last_index}\n\n", socket.recv(1024).force_encoding('iso-8859-1').encode('utf-8'))
  end

  def test_should_return_error_when_invalid_address_is_passed
    socket = TCPSocket.new(CONFIG['host'], 3000)
    socket.write 'GET 40'
    last_index = CONFIG['raw_data'].length - 1
    assert_equal("Invalid Request: Only GET and PUT are accepted and address should be between 0 and #{last_index}\n\n", socket.recv(1024).force_encoding('iso-8859-1').encode('utf-8'))
  end


  def test_should_read_same_value_from_all_the_servers
    address = 5
    (CONFIG['first_process_port']..(CONFIG['first_process_port']+CONFIG['process_count']-1)).to_a.each do |port|
      socket = TCPSocket.new(CONFIG['host'], port)
      socket.write "GET #{address}"
      assert_equal(address, socket.recv(1024).to_i)
    end
  end

  def test_should_update_local_address_value
    address = 1
    new_value = 11
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'])
    socket.write "PUT #{address} #{new_value}"

    # Read from process/server having address value
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'])
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)

    # Read from process/server not having address value
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port']+1)
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)
  end

  def test_should_update_remote_address_value
    address = 7
    new_value = 17
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'])
    socket.write "PUT #{address} #{new_value}"

    # Read from process/server having address value
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'] + 2)
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)

    # Read from process/server not having address value
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'])
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)
  end

end


Test::Unit::UI::Console::TestRunner.run(SharedMemoryTest)