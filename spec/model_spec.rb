require 'spec_helper'

[
  Triglav::Model::Service,
  Triglav::Model::Role,
  Triglav::Model::Host,
].each do |klass|
  describe klass do
    let!(:klass_name) { klass }
    let!(:model_name) { klass.to_s.split('::').last.downcase }

    include_context 'initialize client with model fixtures'

    describe '.create' do
      context 'when a model successfully created' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { { method: :post, path: "/api/#{klass.path}" } }
        let(:res_code) { 204 }
        let(:res_body) { fixture.to_json }

        it {
          result = klass_name.create(client, name: fixture[model_name]['name'])
          expect(result).to be_an_instance_of(klass)
        }
      end
    end

    describe '#show' do
      before {
        subject.client.stub(:dispatch_request).and_return(fixture_for(model_name))
      }

      it {
        response = subject.show
        expect(response).to be == fixture_for(model_name)
      }
    end

    describe '#update' do
      before {
        subject.client.stub(:dispatch_request).and_return(fixture_for(model_name))
      }

      it {
        response = subject.update
        expect(response).to be == fixture_for(model_name)
      }
    end

    describe '#destroy' do
      before {
        subject.client.stub(:dispatch_request).and_return(fixture_for(model_name))
      }

      it {
        response = subject.destroy
        expect(response).to be == fixture_for(model_name)
      }
    end

    describe '#revert' do
      before {
        subject.client.stub(:dispatch_request).and_return(fixture_for(model_name))
      }

      it {
        response = subject.revert
        expect(response).to be == fixture_for(model_name)
      }
    end
  end
end
