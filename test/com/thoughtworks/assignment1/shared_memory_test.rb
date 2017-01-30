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
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'] + 3)
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)

    # Read from process/server not having address value
    socket = TCPSocket.new(CONFIG['host'], CONFIG['first_process_port'])
    socket.write "GET #{address}"
    assert_equal(new_value, socket.recv(1024).to_i)
  end
  
end


Test::Unit::UI::Console::TestRunner.run(SharedMemoryTest)