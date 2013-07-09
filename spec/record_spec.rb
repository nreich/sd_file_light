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
  it { should respond_to :remove_field }
  it { should respond_to :edit_field }
  it { should respond_to :rename_field }
  it { should respond_to :field_names }


  describe 'creating new record' do
    its(:header) { should == record_text[0..3].join }
    its(:structure) { should == record_text[4..32].join }
    its(:field_count) {should == 4 }
  end

  describe 'interacting with fields' do
    let(:missing_field) { "field not appearing in this record" }
    let(:present_field) { record.fields.keys.first }
    let(:new_field) { "new field" }
    let(:new_value) { "new data!" }
    let!(:original_value) { record.field_data(present_field) }

    describe 'checking the existance of a field' do
      it 'should return false if record does not contain the field' do
        expect(record.field_exists?(missing_field)).to be_false
      end
      it 'should return true if record does contain the field' do
        expect(record.field_exists?(present_field)).to be_true
      end
    end

    describe 'retrieving value for a field' do
      context 'field does exist' do
        it 'should return the correct value' do
          record.fields["new field"] = "test value"
          expect(record.field_data("new field")).to eq("test value")
          expect(record.field_data!("new field")).to eq("test value")
        end
      end
      context 'field does not exist' do
        it 'should return nil' do
          expect(record.field_data(missing_field)).to be_nil
        end
        it 'should raise NonExistantField exception when bang method used' do
          expect { record.field_data!(missing_field) }.to raise_error(
            NonExistantField, "field \"#{missing_field}\" does not exist")
        end
      end
    end

    describe 'adding a field' do
      context 'with valid data' do
        it 'should add new field with data if field does not exist' do
          record.add_field(new_field, new_value)
          expect(record.field_data(new_field)).to eq(new_value)
        end
        it 'should change value of an existing field' do
          record.add_field(present_field, new_value)
          expect(record.field_data(present_field)).to eq(new_value)
        end
      end
      context 'with blank data' do
        it 'should not add the new field' do
          record.add_field(new_field, "")
          expect(record.field_exists?(new_field)).to be_false
        end
        it 'should not change an existing field' do
          original_value = record.field_data(present_field)
          record.add_field(present_field, "")
          expect(record.field_data(present_field)).to eq(original_value)
        end
      end
    end

    describe 'removing a field' do
      it 'should result in the field no longer existing' do
        record.remove_field(present_field)
        expect(record.field_exists?(present_field)).to be_false
      end
      it 'should decrease the number of fields by 1' do
        expect { record.remove_field(present_field) }.to change {
          record.fields.size }.by(-1)
      end
      it 'should result in changes to fields if field does not exist' do
        expect { record.remove_field(missing_field) }.to_not change {
          record.fields } 
      end
    end

    describe 'editing a field' do
      context 'if field exists' do
        it 'should change the field value if value in not blank' do
          record.edit_field(present_field, new_value)
          expect(record.field_data(present_field)).to eq(new_value)
        end
        it 'should not change the field value if value is blank' do
          record.edit_field(present_field, "")
          expect(record.field_data(present_field)).to eq(original_value)
        end
      end
      context 'if field does not exist' do
        it 'should not add the field' do
          record.edit_field(missing_field, new_value)
          expect(record.field_exists?(missing_field)).to be_false
        end
      end
    end

    describe 'renaming a field' do
      let(:new_name) { "new name" }

      context 'if field exists' do
        context 'and given a valid field name' do
          before :each do
            record.rename_field(present_field, new_name)
          end

          it 'should result in a field with the new name' do
            expect(record.field_data(new_name)).to eq(original_value)
          end
          it 'should remove the field with the original name' do
            expect(record.field_exists?(present_field)).to be_false
          end
        end
        context 'and field name is blank' do
          it 'is a pending example'
        end
      end
      context 'if field does not exist' do
        it 'should not create a new field' do
          record.rename_field(missing_field, new_name)
          expect(record.field_exists?(new_name)).to be_false
        end
      end
    end

    describe 'retreiving field names' do
      it 'should return an array of all field names' do
        names = record.field_names
        record.fields.each_key { |name| expect(names).to include(name) }
      end
    end

  end

  describe 'convert to string' do
    it 'should return a string with proper sd file formatting' do
      expect(record.to_s).to eq(record_text.join)
    end
  end

end

