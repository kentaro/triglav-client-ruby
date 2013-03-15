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
      { 'id' => 1 },
      { 'id' => 2 },
    ]
  }

  let(:roles) {
    [
      { 'id' => 1 },
      { 'id' => 2 },
    ]
  }

  let(:hosts) {
    [
      { 'id' => 1, 'active' => true  },
      { 'id' => 2, 'active' => false },
      { 'id' => 2, 'active' => true  },
    ]
  }
end

shared_context 'initialize client with model fixtures' do
  include_context 'initialize client'
  include_context 'setup request'

  let(:model) {
    info = fixture_for(model_name)

    klass_name.new(
      client: client,
      info:   info
    )
  }

  let(:service_model) {
    info = fixture_for(:service)['service']

    klass_name.new(
      client: client,
      info:   info
    )
  }

  let(:role_model) {
    info = fixture_for(:role)['role']

    klass_name.new(
      client: client,
      info:   info
    )
  }

  def fixture_for(model_name)
    __send__(model_name)
  end

  let(:service) {
    { 'id' => 1, 'name' => 'test service' }
  }

  let(:role) {
    { 'id' => 1, 'name' => 'test role' }
  }

  let(:host) {
    { 'id' => 1, 'name' => 'test host', 'active' => true }
  }
end
