require 'triglav/client'
require 'triglav/model'

require 'rspec'

unless ENV['LIVE_TEST']
  require 'webmock/rspec'
end

RSpec.configure do |config|
end

shared_context 'initialize client' do
  let(:client) {
    Triglav::Client.new(
      base_url:  ENV['TRIGLAV_BASE_URL'] ||'http://127.0.0.1:3000',
      api_token: ENV['TRIGLAV_API_KEY']  || 'xxxxxxxxxxxxxxxxxxx',
    )
  }
  subject { client }
end

shared_context 'setup request' do
  before {
    if !ENV['LIVE_TEST']
      stub_request(
        endpoint[:method],
        "#{client.base_url}#{endpoint[:path]}?api_token=#{client.api_token}").to_return(
        status: res_code,
        body:   res_body,
      )
    end
  }
end

shared_context 'initialize client with fixtures' do
  include_context 'initialize client'
  include_context 'setup request'

  let(:services) {
    [
      { 'service' => { 'id' => 1 } },
      { 'service' => { 'id' => 2 } },
    ]
  }

  let(:roles) {
    [
      { 'role' => { 'id' => 1 } },
      { 'role' => { 'id' => 2 } },
    ]
  }

  let(:hosts) {
    [
      { 'host' => { 'id' => 1, 'active' => true }  },
      { 'host' => { 'id' => 2, 'active' => false } },
      { 'host' => { 'id' => 2, 'active' => true }  },
    ]
  }
end

shared_context 'initialize client with model fixtures' do
  include_context 'initialize client'
  include_context 'setup request'

  let(:model) {
    info = fixture_for(model_name)[model_name]

    klass_name.new(
      client: client,
      info:   info
    )
  }

  def fixture_for(model_name)
    __send__(model_name)
  end

  let(:service) {
    { 'service' => { 'id' => 1, 'name' => 'test service' } }
  }

  let(:role) {
    { 'role' => { 'id' => 1, 'name' => 'test role' } }
  }

  let(:host) {
    { 'host' => { 'id' => 1, 'name' => 'test host', 'active' => true }  }
  }
end
