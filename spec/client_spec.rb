require 'spec_helper'

describe Triglav::Client do
  describe '.initialize' do
    context 'when no arguments are passed' do
      include_context 'initialize client'

      it {
        expect(subject).to be_an_instance_of Triglav::Client
      }
    end

    context 'when no arguments are passed' do
      it {
        expect { Triglav::Client.new }.to raise_error(ArgumentError)
      }
    end

    context 'when only `base_url` is passed' do
      it {
        expect { Triglav::Client.new(base_url: 'http://example.com/') }.to raise_error(ArgumentError)
      }
    end

    context 'when `api_token` is passed' do
      it {
        expect { Triglav::Client.new(api_token: 'xxxxxxxxxxxxxxxxxxx') }.to raise_error(ArgumentError)
      }
    end
  end

  describe 'endpoint_for' do
    context 'when no arguments except `:type` are passed' do
      include_context 'initialize client'

      it {
        expect(subject.endpoint_for(:services)).to be == {
          method: :get,
          path:   '/api/services',
        }
      }
    end

    context 'when an arguments except `:type` are passed' do
      include_context 'initialize client'

      it {
        expect(subject.endpoint_for(:roles_in, 'triglav')).to be == {
          method: :get,
          path:   '/api/services/triglav/roles',
        }
      }
    end

    context 'when two arguments except `:type` are passed' do
      include_context 'initialize client'

      it {
        expect(subject.endpoint_for(:hosts_in, 'triglav', 'app')).to be == {
          method: :get,
          path:   '/api/services/triglav/roles/app/hosts',
        }
      }
    end

    context 'when no endpoint is found' do
      include_context 'initialize client'

      it {
        expect {
          subject.endpoint_for(:no_such_type).to raise_error(ArgumentError)
        }
      }
    end
  end

  describe '#create' do
    include_context 'initialize client with model fixtures'

    let(:fixture)  { fixture_for('service') }
    let(:endpoint) { Triglav::Model::Service.endpoint_for(:create) }
    let(:res_code) { 204 }
    let(:res_body) { fixture.to_json }

    context 'when model is successfully created' do
      it {
        result = client.create(:service, name: fixture['name'])
        expect(result).to be_an_instance_of(Triglav::Model::Service)
      }
    end

    context 'when an invalid model name is passed' do
      it {
        expect {
          client.create(:no_such_model)
        }.to raise_error(ArgumentError)
      }
    end
  end

  describe '#services' do
    include_context 'initialize client with fixtures'

    let(:endpoint) { subject.endpoint_for(:services) }
    let(:res_code) { 204 }
    let(:res_body) { services.to_json }

    it {
      response = subject.services

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == services.size
    }
  end

  describe '#roles' do
    include_context 'initialize client with fixtures'

    let(:endpoint) { subject.endpoint_for(:roles) }
    let(:res_code) { 204 }
    let(:res_body) { roles.to_json }

    it {
      response = subject.roles

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == roles.size
    }
  end

  describe '#roles_in' do
    include_context 'initialize client with fixtures'

    let(:endpoint) { subject.endpoint_for(:roles_in, 'triglav') }
    let(:res_code) { 204 }
    let(:res_body) { roles.to_json }

    it {
      response = subject.roles_in('triglav')

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == roles.size
    }
  end

  describe '#hosts' do
    include_context 'initialize client with fixtures'

    let(:endpoint) { subject.endpoint_for(:hosts) }
    let(:res_code) { 204 }
    let(:res_body) { hosts.to_json }

    context 'and `with_inactive` option is not passed' do
      it {
        response = subject.hosts

        expect(response).to be_an_instance_of Array
        expect(response.size).to be == (hosts.size - 1)
      }
    end

    context 'when `with_inactive` option passed as true' do
      it {
        response = subject.hosts(with_inactive: true)

        expect(response).to be_an_instance_of Array
        expect(response.size).to be == hosts.size
      }
    end
  end

  describe '#hosts_in' do
    include_context 'initialize client with fixtures'

    context 'when `role` is passed' do
      let(:endpoint) { subject.endpoint_for(:hosts_in, 'triglav', 'app') }
      let(:res_code) { 204 }
      let(:res_body) { hosts.to_json }

      context 'and `with_inactive` option is not passed' do
        it {
          response = subject.hosts_in('triglav', 'app')

          expect(response).to be_an_instance_of Array
          expect(response.size).to be == (hosts.size - 1)
        }
      end

      context 'and `with_inactive` option passed as true' do
        it {
          response = subject.hosts_in('triglav', 'app', with_inactive: true)

          expect(response).to be_an_instance_of Array
          expect(response.size).to be == hosts.size
        }
      end
    end

    context 'when `role` is not passed' do
      let(:endpoint) { subject.endpoint_for(:hosts_in, 'triglav') }
      let(:res_code) { 204 }
      let(:res_body) { hosts.to_json }

      context 'and `with_inactive` option is not passed' do
        it {
          response = subject.hosts_in('triglav')

          expect(response).to be_an_instance_of Array
          expect(response.size).to be == (hosts.size - 1)
        }
      end

      context 'and `with_inactive` option passed as true' do
        it {
          expect {
            subject.hosts_in('triglav', with_inactive: true)
          }.to raise_error(ArgumentError)
        }
      end
    end
  end

  describe '#dispatch_request' do
    include_context 'initialize client'

    context 'when arguments are passed correctly' do
      context 'and request is successfully dispatched' do
        before {
          subject.stub(:do_request).and_return(true)
          subject.stub(:handle_response).and_return("result" => "ok")
        }

        it {
          response = subject.dispatch_request('get', '/foo')

          expect(response).to be_an_instance_of Hash
          expect(response['result']).to be == 'ok'
        }
      end

      context 'and request fails by an error' do
        before {
          subject.stub(:do_request).and_raise(
            Triglav::Client::Error.new('403: 403 Forbidden')
          )
        }

        it {
          expect {
            subject.dispatch_request('get', '/foo')
          }.to raise_error(Triglav::Client::Error)
        }
      end
    end

    context 'when arguments are not passed correctly' do
      context 'and no arguments are passed' do
        it {
          expect {
            subject.dispatch_request
          }.to raise_error(ArgumentError)
        }
      end

      context 'and only `base_url` is passed' do
        it {
          expect {
            subject.dispatch_request('get')
          }.to raise_error(ArgumentError)
        }
      end

      context 'and `api_token` is passed' do
        it {
          expect {
            subject.dispatch_request(nil, '/foo')
          }.to raise_error(ArgumentError)
        }
      end
    end
  end
end
