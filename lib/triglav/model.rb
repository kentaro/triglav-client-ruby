require 'uri'
require 'ostruct'

module Triglav
  module Model
    class Base
      attr_reader :client, :info

      def initialize(args)
        @client = args[:client]
        @info   = OpenStruct.new(args[:info])
      end

      API_ENDPOINT_MAP = {
        create:  { method: :post,   path: '/api/%s.json'           },
        show:    { method: :get,    path: '/api/%s/%s.json'        },
        update:  { method: :post,   path: '/api/%s/%s.json'        },
        destroy: { method: :delete, path: '/api/%s/%s.json'        },
        revert:  { method: :get,    path: '/api/%s/%s/revert.json' },
      }

      def self.endpoint_for (type, *args)
        endpoint = API_ENDPOINT_MAP[type]
        endpoint_path = endpoint[:path] % [self.path, *args.map { |e| URI.encode(e) }]

        { method: endpoint[:method], path: endpoint_path }
      end

      def self.param
        self.to_s.split('::').last.downcase
      end

      def self.build_params(params)
        build_params = {}
        params.each do |key, value|
          build_params["#{self.param}[#{key}]"] = value
        end
        build_params
      end

      def self.create(client, params = {})
        endpoint = endpoint_for(:create)
        result   = client.dispatch_request(
          endpoint[:method],
          endpoint[:path],
          build_params(params),
        )
        new(client: client, info: result[param])
      end

      def show
        endpoint = self.class.endpoint_for(:show, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result[self.class.param])
      end

      def update(params = {})
        endpoint = self.class.endpoint_for(:update, info.name)
        result   = client.dispatch_request(
          endpoint[:method],
          endpoint[:path],
          self.class.build_params(params),
        )
        self.class.new(client: client, info: result[self.class.param])
      end

      def destroy
        endpoint = self.class.endpoint_for(:destroy, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result[self.class.param])
      end

      def revert
        endpoint = self.class.endpoint_for(:revert, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result[self.class.param])
      end
    end

    class Service < Base
      def self.path
        'services'
      end
    end

    class Role < Base
      def self.path
        'roles'
      end
    end

    class Host < Base
      def self.path
        'hosts'
      end

      def add_relation(service, role)
        endpoint = self.class.endpoint_for(:update, info.name)
        result   = client.dispatch_request(
          endpoint[:method],
          endpoint[:path],
          'host[host_relations_attributes][0][service_id]' => service.info.id,
          'host[host_relations_attributes][0][role_id]'    => role.info.id,
        )
        self.class.new(client: client, info: result[self.class.param])
      end
    end
  end
end
