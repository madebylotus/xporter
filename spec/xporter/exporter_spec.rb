require 'spec_helper'

RSpec.describe Xporter::Exporter do
  let(:justin_t) { User.new(name: 'Justin T', email: 'justin.t@gov.ca') }
  let(:barack_o) { User.new(name: 'Barack O', email: 'barack.o@whitehouse.gov') }

  let(:collection) do
    [
      justin_t,
      barack_o
    ]
  end

  shared_context 'simplest exporter' do
    let(:exporter) do
      Class.new(Xporter::Exporter) do
        column(:name)
        column(:email)
      end
    end
  end

  describe 'DSL' do
    subject do
      Class.new(Xporter::Exporter)
    end

    describe '.column' do
      it 'adds the column' do
        expect do
          subject.class_eval do
            column(:name)
          end
        end.to change { subject._columns.count }.by(1)
      end
    end

    describe '.model' do
      let(:resource_class) { Class }

      it 'stores the resource class' do
        expect do
          subject.class_eval do
            model Class
          end
        end.to change { subject._resource_class }.from(nil).to(resource_class)
      end
    end

    describe '.transform' do
      it 'stores the transformation block' do
        expect do
          subject.class_eval do
            transform do |record, context|
              record.object_id
            end
          end
        end.to change { subject._record_transform }.from(nil)
      end

      it 'uses the return value of the tranform' do
        subject.class_eval do
          transform do |record, context|
            record.object_id
          end
        end

        exporter = subject.new
        expect(exporter.send(:transform, justin_t)).to eq(justin_t.object_id)
      end
    end
  end

  describe '.generate' do
    subject { exporter.generate(collection) }

    let(:csv) { CSV.parse(subject, headers: true) }

    context 'simplest case' do
      include_context 'simplest exporter'

      it 'wrote the headers' do
        expect(csv.headers).to eq(['Name', 'Email'])
      end

      it 'included the first user' do
        expect(csv[0].to_hash).to eq('Name' => justin_t.name, 'Email' => justin_t.email)
      end

      it 'included the second user' do
        expect(csv[1].to_hash).to eq('Name' => barack_o.name, 'Email' => barack_o.email)
      end
    end
  end

  describe '.stream' do
    subject { exporter }
    let(:stream) { double(StringIO, write: nil) }

    context 'simplest case' do
      include_context 'simplest exporter'

      it 'wrote the headers' do
        headers = CSV.generate_line(['Name', 'Email'])

        stream!

        expect(stream).to have_received(:write).with(headers)
      end

      it 'included the first user' do
        line = CSV.generate_line([justin_t.name, justin_t.email])

        stream!

        expect(stream).to have_received(:write).with(line)
      end

      it 'included the second user' do
        line = CSV.generate_line([barack_o.name, barack_o.email])

        stream!

        expect(stream).to have_received(:write).with(line)
      end
    end

    def stream!
      subject.stream(collection, stream)
    end
  end
end
