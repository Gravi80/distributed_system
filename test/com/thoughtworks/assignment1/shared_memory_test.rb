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
end


Test::Unit::UI::Console::TestRunner.run(TC_MyTest)