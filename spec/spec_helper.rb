require 'triglav/client'

require 'rspec'
RSpec.configure do |config|
end

shared_context 'initialize client' do
  let(:client) {
    Triglav::Client.new(base_url: 'http://example.com/', api_token: 'xxxxxxxxxx')
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
