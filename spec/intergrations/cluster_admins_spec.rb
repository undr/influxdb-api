require 'spec_helper'

describe 'cluster_admins', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.cluster_admins }

  before{ subject.all.each{|u| subject.delete(u['name']) if u['name'] != 'root' } }
  after{ subject.all.each{|u| subject.delete(u['name']) if u['name'] != 'root' } }

  describe '.all' do
    it 'returns list of users' do
      expect(subject.all).to eq([{ 'name' => 'root' }])
    end
  end

  describe '.create' do
    it 'creates cluster admin' do
      subject.create(name: 'username', password: 'pass')
      expect(subject.all).to match_array([{ 'name' => 'root' }, { 'name' => 'username' }])
    end

    context 'when there is user with same name' do
      it 'raises error' do
        expect{ subject.create(name: 'root', password: 'pass') }.to raise_error(
          Influxdb::Api::Client::Errors::BadRequest, '[400] User root already exists'
        )
      end
    end
  end

  describe '.update' do
    context 'when user exists' do
      let(:new_client){ Influxdb::Api::Client.new(new_config) }
      let(:new_config) do
        Influxdb::Api::Configuration.new.tap do |c|
          c.user = 'username'
          c.password = 'pass1'
        end
      end

      before{ subject.create(name: 'username', password: 'pass') }

      it 'updates user attributes' do
        expect{ subject.update('username', password: 'pass1') }.not_to raise_error
        expect{ new_client.version }.not_to raise_error
      end
    end

    context 'when user does not exist' do
      it 'raises error' do
        expect{ subject.update('username', password: 'pass') }.to raise_error(
          Influxdb::Api::Client::Errors::BadRequest, '[400] Invalid user name username'
        )
      end
    end
  end

  describe '.delete' do
    context 'when user does not exist' do
      it 'returns false' do
        expect(subject.delete('username')).to be_falsy
      end
    end

    context 'when user exists' do
      before{ subject.create(name: 'username', password: 'pass') }

      it 'removes user and returns true' do
        expect(subject.delete('username')).to be_truthy
      end
    end
  end
end
