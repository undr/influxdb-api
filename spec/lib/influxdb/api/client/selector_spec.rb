require 'spec_helper'

describe Influxdb::Api::Client::Selector do
  describe 'Random' do
    subject{ Influxdb::Api::Client::Selector::Random.new }

    describe '#select_from' do
      specify{ expect(subject.select_from([1, 2, 3])).not_to be_nil }
    end
  end

  describe 'RoundRobin' do
    subject{ Influxdb::Api::Client::Selector::RoundRobin.new }

    describe '#select_from' do
      specify do
        expect(subject.select_from([1, 2, 3])).to eq(1)
        expect(subject.select_from([1, 2, 3])).to eq(2)
        expect(subject.select_from([1, 2, 3])).to eq(3)
        expect(subject.select_from([1, 2, 3])).to eq(1)
      end
    end
  end
end
