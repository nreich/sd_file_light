require 'sd_file_light/record'

describe Record do

  let(:record_text) {IO.readlines(File.dirname(__FILE__) +
                                  '/record_tests_sdf.txt') }
  subject(:record) { Record.new(record_text) }

  it { should respond_to :header }
  it { should respond_to :structure }
  it { should respond_to :fields }

end

