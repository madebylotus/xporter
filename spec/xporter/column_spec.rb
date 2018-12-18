require 'spec_helper'

RSpec.describe Xporter::Column do
  describe '.data' do
    let(:author) { double(name: 'Justin T') }
    let(:model) { double(author: author, author_name: author.name) }

    context 'when a block is provided' do
      subject do
        described_class.new(:author, 'Article of Importance')  { |m| m.author_name }
      end

      it 'returns the data' do
        expect(data).to eq(author.name)
      end
    end

    context 'when no block given' do
      subject { described_class.new(:author_name, 'Article of Importance') }

      it 'returns the data' do
        expect(data).to eq(author.name)
      end
    end

    def data
      subject.data(model)
    end
  end

  describe '.title_from' do
    let(:resource_class) do
      Class.new do
      end
    end

    context 'when title provided' do
      subject { described_class.new(:author, 'Authored by') }

      it 'returns the custom title' do
        expect(title).to eq('Authored by')
      end
    end

    context 'when fallback to attribute name' do
      subject { described_class.new(:author) }

      it 'falls back to the attribute name' do
        expect(title).to eq('Author')
      end
    end

    context 'when I18n available' do
      subject { described_class.new(:author) }

      let(:resource_class) do
        Class.new do
          def self.human_attribute_name(attribute_name)
            attribute_name.upcase
          end
        end
      end

      it 'returns the humanized name' do
        expect(title).to eq(:AUTHOR)
      end
    end

    def title
      subject.title_from(resource_class)
    end
  end
end
