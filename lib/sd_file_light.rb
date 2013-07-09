class SDFileLight
require 'sd_file_light/record'

  attr_reader :records

  def initialize()
    @records = []
  end

  def add_records(source)
    if source.class == String
      process_file(source)
    elsif source.class == Array
      @records.concat(source)
    end
  end

  def add_record(record)
    @records << record
  end

  def export(location)
    File.open(location, "w") do |file|
      @records.each do |record|
        file.puts record
      end
    end
  end


private

  def process_file(file)
    record_lines = []
    IO.foreach(file) do |line|
      unless line == "$$$$\n"
        record_lines << line
      else
        @records << Record.new(record_lines)
        record_lines = []
      end
    end
  end
end

