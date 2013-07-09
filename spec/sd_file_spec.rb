require 'sd_file_light'

describe SDFileLight do

  subject(:sd_file) { SDFileLight.new() }
  let(:file) { File.dirname(__FILE__) + '/sdf_tests.txt' } 
  let(:records_in_file) { 2 }
  let(:record_text) {record_text = IO.readlines(File.dirname(__FILE__) +
                                  '/record_tests_sdf.txt') } 
  let(:record) { Record.new(record_text) }

  it { should respond_to :records }

  describe 'creating a new sd file' do
    it 'should produce an empty sd file' do
      expect(sd_file.class).to eq(SDFileLight)
      expect(sd_file.records).to be_true
    end
  end

  describe 'adding new records' do
    context 'by passing a file path' do
      it 'should add the records' do
        sd_file.add_records(file)
        expect(sd_file.records.size).to eq(records_in_file)
      end
    end
    context 'by passing an array of records' do
      it 'should add the records' do
        records_to_add = []
        2.times do
          records_to_add << record
        end
        sd_file.add_records(records_to_add)
        expect(sd_file.records.size).to eq(records_in_file)
      end 
    end
  end


  describe 'added a single record to sd file' do
    it 'should add the record' do
      sd_file.add_record(record)
      expect(sd_file.records.include?(record)).to be_true
    end
  end

  describe 'export to file' do
    it 'should properly format the sd file' do
      export_location = File.dirname(__FILE__) + '/sdf_export.txt' 
      text = IO.read(file)
      sd_file.add_records(file)
      sd_file.export(export_location)
      exported_text = IO.read(export_location)
      expect(exported_text).to eq(text)
    end
  end


end
