require 'sd_file_light/record'

describe Record do

  subject(:record) { Record.new(record_text) }
  let(:record_text) {IO.readlines(File.dirname(__FILE__) +
                                  '/record_tests_sdf.txt') }

  it { should respond_to :header }
  it { should respond_to :structure }
  it { should respond_to :fields }
  it { should respond_to :field_exists? }
  it { should respond_to :field_data }
  it { should respond_to :field_data! }
  it { should respond_to :field_count }
  it { should respond_to :add_field }


  context 'creating new record' do
    its(:header) { should == record_text[0..3].join }
    its(:structure) { should == record_text[4..32].join }
    its(:field_count) {should == 4 }
  end

  context 'field does not exist' do
    let(:non_existant_field_name) { "non existant field" }
    it 'should return false when existance of field checked' do
      record.field_exists?(non_existant_field_name).should  be_false
    end
    it 'should return nil for the field data' do
      record.field_data(non_existant_field_name).should == nil
    end
    it 'should raise an instance of NonExistantField
        when bang method for field data requested' do
      lambda { record.field_data!(non_existant_field_name) }.should
        raise_error(NonExistantField, "field \"#{non_existant_field_name}\" 
                    does not exist") 
    end
  end

  context 'field exists' do
    let(:valid_field_name) { "ID" }
    it 'should return true when existance of field checked' do
      record.field_exists?(valid_field_name).should be_true
    end
    it 'should return the correct field data' do
      record.field_data(valid_field_name).should == "304"
      record.field_data!(valid_field_name).should == "304"
    end
  end

  context 'adding a field' do
    let(:new_field) { "new field" }

    context 'with valid data' do
      let(:field_value) { "new value" }

      it 'should add a field with the currently non-existant name' do
        record.add_field(new_field, field_value)
        record.field_exists?(new_field).should be_true
      end

      it 'should have the right value in it' do
        record.add_field(new_field, field_value)
        record.field_data(new_field).should eq(field_value)
      end

      it 'should increase the fields hash size by 1' do
        lambda { record.add_field(new_field, field_value) 
          }.should change{record.fields.size}.by(1)
      end

      context 'when field already exists' do
        
        let(:field_name) { "ID" }

        it 'should overwrite the previous value' do
          old_value = record.field_data(new_field)
          record.add_field(new_field, field_value)
          record.field_data(new_field).should_not eq(old_value)
        end

      end

    end

    context 'with blank data' do

      it 'should not result in a field with that name' do
        record.add_field(new_field, "")
        record.field_exists?(new_field).should be_false
      end

      it 'should not change size of fields hash' do
        lambda { record.add_field(new_field, "")
         }.should change{record.fields.size}.by(0)
      end

    end     
      
  end


end

