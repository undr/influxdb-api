require 'spec_helper'

describe Influxdb::Api::Client::Connection do
  subject{ Influxdb::Api::Client::Connection.new('http://localhost:8086', nil) }

  describe '#full_path' do
    let(:path){ '/some/path' }
    let(:params){ { key1: 'value1', key2: 'value2' } }
    let(:result){ '/some/path?key1=value1&key2=value2' }

    specify{ expect(subject.full_path(path, params)).to eq(result) }
  end

  describe '#dead?' do
    specify{ expect(subject.dead?).to be_falsy }

    context do
      before{ subject.dead! }
      specify{ expect(subject.dead?).to be_truthy }
    end
  end

  describe '#dead!', time_freeze: '16.9.2014 00:00:00 +0700' do
    let(:now){ Time.parse('16.9.2014 00:00:00 +0700') }

    specify{ expect{ subject.dead! }.to change{ subject.failures }.from(0).to(1) }
    specify{ expect{ subject.dead! }.to change{ subject.dead? }.from(false).to(true) }
    specify{ expect{ subject.dead! }.to change{ subject.dead_since }.from(nil).to(now) }
    specify{ expect(subject.dead!).to eq(subject) }
  end

  describe '#alive!' do
    before{ subject.dead! }

    specify{ expect{ subject.alive! }.to change{ subject.dead? }.from(true).to(false) }
    specify{ expect{ subject.alive! }.not_to change{ subject.failures } }
    specify{ expect(subject.alive!).to eq(subject) }
  end

  describe '#healthy!' do
    before{ subject.dead! }

    specify{ expect{ subject.healthy! }.to change{ subject.dead? }.from(true).to(false) }
    specify{ expect{ subject.healthy! }.to change{ subject.failures }.from(1).to(0) }
    specify{ expect(subject.healthy!).to eq(subject) }
  end

  describe '#resurrect!' do
    before{ subject.dead! }

    context 'when connection is resurrectable' do
      before{ allow(subject).to receive(:resurrectable?).and_return(true) }

      specify{ expect{ subject.resurrect! }.to change{ subject.dead? }.from(true).to(false) }
      specify{ expect(subject.resurrect!).to eq(subject) }
    end

    context 'when connection is not resurrectable' do
      before{ allow(subject).to receive(:resurrectable?).and_return(false) }

      specify{ expect{ subject.resurrect! }.not_to change{ subject.dead? } }
      specify{ expect(subject.resurrect!).to eq(subject) }
    end
  end

  describe '#resurrectable?' do


  end
end
