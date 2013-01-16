require 'triglav/client'
require 'triglav/model'

require 'rspec'
RSpec.configure do |config|
end

shared_context 'initialize client' do
  let(:client) {
    Triglav::Client.new(
      base_url:  'http://example.com/',
      api_token: 'xxxxxxxxxxxxxxxxxxx',
    )
  }
  subject { client }
end

shared_context 'initialize client with fixtures' do
  include_context 'initialize client'

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

  let(:model) {
    info = fixture_for(model_name)[model_name]

    klass_name.new(
      client: client,
      info:   info
    )
  }

  subject { model }

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
