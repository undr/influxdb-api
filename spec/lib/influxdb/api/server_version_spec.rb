require 'spec_helper'

describe Influxdb::Api::ServerVersion do
  let(:source){ 'InfluxDB v0.7.3 (git: 023abcdef) (leveldb: 1.8)' }

  subject{ Influxdb::Api::ServerVersion.new(source) }

  describe '#to_s' do
    specify{ expect(subject.to_s).to eq(source) }
  end

  describe '#major' do
    specify{ expect(subject.major).to eq(0) }
  end

  describe '#minor' do
    specify{ expect(subject.minor).to eq(7) }
  end

  describe '#patch' do
    specify{ expect(subject.patch).to eq(3) }
  end

  describe '#git' do
    specify{ expect(subject.git).to eq('023abcdef') }
  end

  context 'engine' do
    subject{ Influxdb::Api::ServerVersion.new(source).engine }

    describe '#to_s' do
      specify{ expect(subject.to_s).to eq('leveldb: 1.8.0') }
    end

    describe '#name' do
      specify{ expect(subject.name).to eq('leveldb') }
    end

    describe '#major' do
      specify{ expect(subject.major).to eq(1) }
    end

    describe '#minor' do
      specify{ expect(subject.minor).to eq(8) }
    end

    describe '#patch' do
      specify{ expect(subject.patch).to eq(0) }
    end
  end
end
