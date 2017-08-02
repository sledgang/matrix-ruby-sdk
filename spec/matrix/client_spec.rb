require 'spec_helper'

RSpec.describe Matrix::Client do
  it 'should get versions' do
    stub_request(:get, 'https://matrix.org/_matrix/client/versions')
      .to_return(status: 200, body: { versions: ['r0.0.1'] }.to_json, headers: {})
    expect(Matrix::Client.versions).not_to be_empty
  end

  it 'logs in' do
    stub_request(:post, 'https://matrix.org/_matrix/client/r0/login')
      .with { |request| request.body =~ /failure/ }
      .to_return(status: 403, body: { errcode: 'M_FORBIDDEN' }.to_json, headers: {})
    stub_request(:post, 'https://matrix.org/_matrix/client/r0/login')
      .with { |request| request.body =~ /success/ }
      .to_return(status: 200, body: { user_id: '@admin:matrix.org', access_token: 'abc123', home_server: 'matrix.org', device_id: 'aaabbbccc' }.to_json, headers: {})
    client = Matrix::Client.new 'https://matrix.org',
                                           'admin',
                                           'failure'
    expect { client.login }.to raise_exception(TypeError)
    expect(client.token).to be_nil

    client = Matrix::Client.new 'https://matrix.org',
                                           'admin',
                                           'success'
    expect { client.login }.not_to raise_error
    expect(client.token).not_to be_nil
  end

  it 'logs out' do
    stub_request(:post, 'https://matrix.org/_matrix/client/r0/login')
      .with { |request| request.body =~ /success/ }
      .to_return(status: 200, body: { user_id: '@admin:matrix.org', access_token: 'abc123', home_server: 'matrix.org', device_id: 'aaabbbccc' }.to_json, headers: {})
    stub_request(:post, 'https://matrix.org/_matrix/client/r0/logout')
      .to_return(status: 200)
    client = Matrix::Client.new 'https://matrix.org',
                                           'admin',
                                           'failure'
    expect { client.logout }.to raise_exception(RuntimeError)
    client = Matrix::Client.new 'https://matrix.org',
                                           'admin',
                                           'success'
    client.login
    expect { client.logout }.not_to raise_error
    expect(client.token).to be_nil
    expect { client.logout }.to raise_error(RuntimeError)
  end
end
