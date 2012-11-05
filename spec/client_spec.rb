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
        expect { Triglav::Client.new }.to raise_error(ArgumentError)
      }
    end

    context 'when `api_token` is passed' do
      it {
        expect { Triglav::Client.new }.to raise_error(ArgumentError)
      }
    end
  end

  describe '#services' do
    include_context 'initialize client with fixtures'

    before {
      subject.stub(:dispatch_request).and_return(services)
    }

    it {
      response = subject.services

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == services.size
    }
  end

  describe '#roles' do
    include_context 'initialize client with fixtures'

    before {
      subject.stub(:dispatch_request).and_return(roles)
    }

    it {
      response = subject.roles

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == roles.size
    }
  end

  describe '#roles_in' do
    include_context 'initialize client with fixtures'

    before {
      subject.stub(:dispatch_request).and_return(roles)
    }

    it {
      response = subject.roles_in('triglav')

      expect(response).to be_an_instance_of Array
      expect(response.size).to be == roles.size
    }

    context 'when `service` is not passed' do
      include_context 'initialize client with fixtures'

      it {
        expect { subject.roles_in }.to raise_error(ArgumentError)
      }
    end
  end

  describe '#hosts' do
    include_context 'initialize client with fixtures'

    before {
      subject.stub(:dispatch_request).and_return(hosts)
    }

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

    before {
      subject.stub(:dispatch_request).and_return(hosts)
    }

    context 'when `role` is passed' do
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
          subject.stub(:do_request).and_return('{ "result": "ok" }')
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