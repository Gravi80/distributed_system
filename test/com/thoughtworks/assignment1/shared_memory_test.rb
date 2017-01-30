require 'test/unit'
require 'test/unit/ui/console/testrunner'

class TC_MyTest < Test::Unit::TestCase

  def self.startup
    require_relative '../../../../src/com/thoughtworks/assignment1/start'
  end

  def self.shutdown
    `kill -9 $(lsof -Pti @localhost:3000-3003 -sTCP:LISTEN)`
  end

  def test_should_data
    port = 3000
    socket = TCPSocket.new(CONFIG['host'], port)
    socket.write 'GET 0'
    assert_equal(0,socket.recv(1024).to_i)
  end

end

Test::Unit::UI::Console::TestRunner.run(TC_MyTest)