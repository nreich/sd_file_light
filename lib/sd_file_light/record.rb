class Record

  attr_reader :header, :structure, :fields

  def initialize(lines)
    @header = lines[0..3].join #header defined as first 4 lines in sdf standard
    @structure = structure_lines(lines)
    @fields = field_array(lines)
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
