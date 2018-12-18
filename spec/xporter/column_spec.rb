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
end
