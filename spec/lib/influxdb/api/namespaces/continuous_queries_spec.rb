require 'spec_helper'

describe Influxdb::Api::Namespaces::ContinuousQueries do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::ContinuousQueries.new(client, 'dbname') }

  describe '#all' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/continuous_queries').
        to_return(
          status: 200,
          body: '[{"id":1,"query":"select type from events into events.[page_id]"}]',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    specify{ expect(subject.all).to eq([{ 'id' =>1, 'query' => 'select type from events into events.[page_id]' }]) }
  end

  describe '#create' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/db/dbname/continuous_queries').
        with(
          body: '{"query":"select type from events into events.[page_id]"}',
          headers: { 'Content-Type' => 'application/json' }
        ).to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.create('select type from events into events.[page_id]')).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/db/dbname/continuous_queries/1').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete(1)).to be_truthy }
  end
end
