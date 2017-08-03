require 'spec_helper'

RSpec.describe Matrix::Client do
  it 'should get versions' do
    VCR.use_cassette('versions') do
      expect(Matrix::Client.versions).not_to be_empty
    end
  end

  it 'logs in' do
    VCR.use_cassette('login') do
      client = Matrix::Client.new 'http://localhost:8008',
                                  'admin',
                                  'failure'
      expect { client.login }.to raise_exception(TypeError)
      expect(client.token).to be_nil

      client = Matrix::Client.new 'http://localhost:8008',
                                  'admin',
                                  'success'
      expect { client.login }.not_to raise_error
      expect(client.token).not_to be_nil
    end
  end

  it 'logs out' do
    VCR.use_cassette('logout') do
      client = Matrix::Client.new 'http://localhost:8008',
                                  'admin',
                                  'failure'
      expect { client.logout }.to raise_exception(RuntimeError)
      client = Matrix::Client.new 'http://localhost:8008',
                                  'admin',
                                  'success'
      client.login
      expect { client.logout }.not_to raise_error
      expect(client.token).to be_nil
      expect { client.logout }.to raise_error(RuntimeError)
    end
  end
end
