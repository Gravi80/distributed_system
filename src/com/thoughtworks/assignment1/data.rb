require_relative 'config'
require_relative 'address_mapper'

module Distributed
  class Data
    def initialize
      @address_mapper = AddressMapper.new
    end

    #   0 => [ 0,1 ]
    #   1 => [ 2,3 ]
    #   2 => [ 4,5 ]
    #   3 => [ 6,7,8 ]
    def for_process(number)
      bin_length = (CONFIG['raw_data'].length/CONFIG['process_count'].to_f).round
      start_index = number * bin_length
      if last_process(number)
        bin_length = CONFIG['raw_data'].length
      end
      CONFIG['raw_data'][start_index, bin_length]
    end

    def get_process_number_for(address)
      @address_mapper.get_process_for(address)
    end

    def get_dd_index_mapping_with_original_data(process_number)
      @address_mapper.raw_data_and_dd_index_map(process_number)
    end

    private
    def last_process(number)
      number + 1 == CONFIG['process_count']
    end

  end
end