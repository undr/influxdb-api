require 'spec_helper'

describe Influxdb::Api::Client::Response do
  describe '#initialize' do
    let(:iso_8859){ 'Hello Encoding!'.encode(Encoding::ISO_8859_1) }

    subject{ Influxdb::Api::Client::Response.new(200, iso_8859, {}) }

    specify{ expect(subject.body.encoding.name).to eq('UTF-8') }
  end
end
