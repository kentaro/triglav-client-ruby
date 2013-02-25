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
      context 'when a model is successfully created' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { klass.endpoint_for(:create) }
        let(:res_code) { 204 }
        let(:res_body) { fixture.to_json }

        it {
          result = klass_name.create(client, name: fixture[model_name]['name'])
          expect(result).to be_an_instance_of(klass)
        }
      end
    end

    describe '#show' do
      context 'when a model is successfully shown' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { model.class.endpoint_for(:show, model.info.name) }
        let(:res_code) { 200 }
        let(:res_body) { fixture.to_json }

        it {
          result = model.show
          expect(result).to be_an_instance_of(klass)
        }
      end
    end

    describe '#update' do
      context 'when a model is successfully updated' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { model.class.endpoint_for(:update, model.info.name) }
        let(:res_code) { 200 }
        let(:res_body) { fixture.to_json }

        it {
          result = model.update(name: fixture[model_name]['name'])
          expect(result).to be_an_instance_of(klass)
        }
      end
    end

    describe '#destroy' do
      context 'when a model is successfully updated' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { model.class.endpoint_for(:destroy, model.info.name) }
        let(:res_code) { 200 }
        let(:res_body) { fixture.to_json }

        it {
          result = model.destroy
          expect(result).to be_an_instance_of(klass)
        }
      end
    end

    describe '#revert' do
      context 'when a model is successfully updated' do
        let(:fixture)  { fixture_for(model_name) }
        let(:endpoint) { model.class.endpoint_for(:revert, model.info.name) }
        let(:res_code) { 200 }
        let(:res_body) { fixture.to_json }

        it {
          result = model.revert
          expect(result).to be_an_instance_of(klass)
        }
      end
    end
  end
end
