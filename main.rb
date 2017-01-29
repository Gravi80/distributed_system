require_relative 'server'
require_relative 'data'
require_relative 'dsm'

# server = Server.new(4000)
# server.accept_requests

dd = Distributed::Data.new

dsm = Dsm.new(dd.for_process(0), dd.get_dd_index_mapping_with_original_data(0))
print dsm.read(0)
dsm.write(0,6)
print dsm.read(0)

