class AddressMapper
  def initialize
    @process_data_map = nil
  end

  def get_process_for(address)
    raw_data_index_map_with_dd
    @process_data_map.each do |process_number, indexes|
      return process_number if address.between?(indexes.values.first, indexes.values.last)
    end
  end

  def raw_data_and_dd_index_map(process_number)
    raw_data_index_map_with_dd
    @process_data_map[process_number]
  end

  private

  # {
  #   0 => {
  #           0 => 0
  #           1 => 1
  #
  #        },
  #   1 =>  {
  #           0 => 2
  #           1 => 3
  #
  #        },
  #   2 =>  {
  #           0 => 4
  #           1 => 5
  #
  #       },
  #   3 => {
  #          0 => 6
  #          1 => 7
  #          2 => 8
  #
  #      }
  # }

  def raw_data_index_map_with_dd
    return @process_data_map if @process_data_map
    process_data = {}
    bin_length = (CONFIG['raw_data'].length/CONFIG['process_count'].to_f).round
    CONFIG['process_count'].times do |process_number|
      start_index = process_number * bin_length
      end_index = (start_index + bin_length - 1)
      if process_number + 1 == CONFIG['process_count']
        end_index = CONFIG['raw_data'].length - 1
      end
      ((end_index - start_index)+1).times do |index|
        process_data[process_number] = process_data[process_number] || {}
        process_data[process_number][index] = start_index
        start_index = start_index+1
      end
    end
    @process_data_map = process_data
  end

end