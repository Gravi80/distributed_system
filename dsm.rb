require_relative 'address_mapper'

class Dsm

  def initialize(data, index_map)
    @data = data
    @index_map = index_map
  end

  def write(address, new_value)
    if locally_present?(address)
      @index_map.each do |key, value|
        if value == address
          @data[key] = new_value
        end
      end
    else
      process_number = AddressMapper.new.get_process_for(address)
      puts process_number

    end
  end

  def read(address)
    if locally_present?(address)
      @index_map.each do |key, value|
        return @data[key] if value == address
      end
    else
      process_number = AddressMapper.new.get_process_for(address)
      puts process_number
    end
  end

  private
  def locally_present?(address)
    @index_map.values.include?(address)
  end
end