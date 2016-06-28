require './spec/rails_helper'

describe HashToArQuery do
  describe 'prepare' do
    subject { HashToArQuery.prepare }
    it { should be_a(HashToArQuery::Builder) }
  end

  describe 'build' do
    context 'all deny' do
      let(:builder) { HashToArQuery.prepare }
      subject { builder.add({a: :deny, b: :deny}).addition }
      it { should eq({}) }
    end

    context 'all' do
      let(:builder) { HashToArQuery.prepare(allow: {a: :all, b: :all, c: :all}) }
      let(:addition) { {a: 'string', b: 1, c: true} }
      it { expect(builder.add(addition).addition).to eq(addition) }
    end

    context 'string' do
      let(:builder) { HashToArQuery.prepare(allow: {a: :string, b: :string}) }
      let(:addition) { {a: 'string', b: 1} }
      it { expect(builder.add(addition).addition).to eq({a: 'string', b: '1'}) }
    end

    context 'number' do
      let(:builder) { HashToArQuery.prepare(allow: {a: :integer, b: :integer}) }
      let(:addition) { {a: '1', b: 1} }
      it { expect(builder.add(addition).addition).to eq({a: 1, b: 1}) }
    end

    context 'array' do
      let(:builder) { HashToArQuery.prepare(allow: {a: [:array, :integer], b: :integer}) }
      let(:addition) { {a: [1, '1'], b: [1]} }
      it { expect(builder.add(addition).addition).to eq({a: [1, 1], b: nil}) }
    end
  end
end