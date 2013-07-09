class Record

  attr_reader :header, :structure, :fields

  def initialize(lines)
    @header = lines[0..3].join #header defined as first 4 lines in sdf standard
    @structure = structure_lines(lines)
    @fields = field_array(lines)
  end

  def field_exists?(name)
    @fields.has_key?(name)
  end

  def field_data(name)
    @fields[name]
  end

  def field_data!(name)
    unless @fields.has_key?(name)
      raise NonExistantField, "field \"#{name}\" does not exist", caller
    end
    @fields[name]
  end

  def field_count
    @fields.size
  end

  def add_field(name, value)
    unless name.empty? 
      @fields[name] = value.chomp unless value.empty?
    end
  end
    
  def remove_field(name)
    @fields.delete(name)
  end

  def edit_field(name, value)
    add_field(name, value) unless field_exists?(name) == false
  end

  def rename_field(old_name, new_name)
    if field_exists?(old_name) && new_name.empty? == false
      @fields[new_name] = @fields[old_name]
      remove_field(old_name)
    end
  end

  def field_names
    @fields.keys
  end

  def to_s
    field_string = ""
    @fields.each_pair do |key, value| 
      field_string += ">  <" + key + ">" + "\n" + value + "\n\n"
		end 
		record_string = @header + @structure + field_string + "$$$$\n"
	end  


private

  #sdf standard defines mol_file (aka structure) as all lines between header
  #and the line: "M END" 
  def structure_lines(lines)
    last_structure_line = lines.index{ |line| line =~ /\AM END/ }
    lines[4..last_structure_line].join
  end

  #sdf standard defines the field name line as: "> <NAME>"
  #every line between the field name and a blank line is the text of that field
  #n.b. a field cannot have blank lines in its field
  def field_array(lines)
    entries = []
    text = lines.join
    text.scan(/^>.+<(.+)>\n(.+\n)+\n/) do |name, data| 
      entries << [name, data.chomp]
    end
    Hash[entries]
  end
end

class NonExistantField < StandardError
end
