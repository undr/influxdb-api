require 'spec_helper'

describe 'users', version: '<0.8.0', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.databases('db_name').users }

  before do
    client.databases.create('db_name')
    subject.all.each{|u| subject.delete(u['name']) }
  end

  after{ client.databases.delete('db_name') }

  describe '.all' do
    context 'when there are no users' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some users' do
      before do
        subject.create(name: 'username1', password: 'mypass1')
        subject.create(name: 'username2', password: 'mypass2')
      end

      it 'returns the list of users' do
        expect(subject.all).to match_array([
          { 'name' => 'username1', 'isAdmin' => false },
          { 'name' => 'username2', 'isAdmin' => false }
        ])
      end
    end
  end

  describe '.create' do
    it 'creates a new user with given name' do
      expect{ subject.create(name: 'username', password: 'mypass') }.to change{ subject.all.size }.from(0).to(1)
    end

    context 'when there is user with the same name' do
      before{ subject.create(name: 'username', password: 'mypass') }

      it 'raises error' do
        expect{ subject.create(name: 'username', password: 'mypass') }.to raise_error(
          Influxdb::Api::Client::Errors::BadRequest, '[400] User username already exists'
        )
      end
    end
  end

  describe '.update' do
    context 'when user does not exist' do
      it 'raises error' do
        expect{ subject.update('username', admin: true) }.to raise_error(
          Influxdb::Api::Client::Errors::BadRequest, '[400] Invalid username username'
        )
      end
    end

    context 'when user exists' do
      before{ subject.create(name: 'username', password: 'mypass') }

      it 'updates user attributes' do
        subject.update('username', admin: true)
        expect(subject.all).to eq([{ 'name' => 'username', 'isAdmin' => true }])
      end
    end
  end

  describe '.find' do
    context 'when user does not exist' do
      it 'returns nil' do
        expect(subject.find('username2')).to be_nil
      end
    end

    context 'when user exists' do
      before{ subject.create(name: 'username', password: 'mypass') }

      it 'returns user' do
        expect(subject.find('username')).to eq('name' => 'username', 'isAdmin' => false)
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
      before{ subject.create(name: 'username', password: 'mypass') }

      it 'removes db and returns true' do
        expect(subject.delete('username')).to be_truthy
      end
    end
  end
end
