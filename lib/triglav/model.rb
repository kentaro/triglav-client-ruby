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
        path = endpoint[:path] % [self.path, *args.map { |e| URI.encode(e) }]

        { method: endpoint[:method], path: path }
      end

      def self.create(client, params = {})
        endpoint = endpoint_for(:create)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path], params)
        new(client: client, info: result)
      end

      def show
        endpoint = self.class.endpoint_for(:show, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result)
      end

      def update(params = {})
        endpoint = self.class.endpoint_for(:update, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path], params)
        self.class.new(client: client, info: result)
      end

      def destroy
        endpoint = self.class.endpoint_for(:destroy, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result)
      end

      def revert
        endpoint = self.class.endpoint_for(:revert, info.name)
        result   = client.dispatch_request(endpoint[:method], endpoint[:path])
        self.class.new(client: client, info: result)
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
    end
  end
end
