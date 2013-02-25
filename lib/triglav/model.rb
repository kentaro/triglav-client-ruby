require 'ostruct'

module Triglav
  module Model
    class Base
      attr_reader :client, :info

      def initialize(args)
        @client = args[:client]
        @info   = OpenStruct.new(args[:info])
      end

      def self.create(client, params = {})
        result = client.dispatch_request(:post, "/api/#{path}", params)
        self.new(client: client, info: result)
      end

      def show
        client.dispatch_request(:get, "/api/#{self.class.path}/#{info.name}.json")
      end

      def update(params = {})
        client.dispatch_request(:put, "/api/#{self.class.path}/#{info.name}.json", params)
      end

      def destroy
        client.dispatch_request(:delete, "/api/#{self.class.path}/#{info.name}.json")
      end

      def revert
        client.dispatch_request(:put, "/api/#{self.class.path}/#{info.name}/revert.json")
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
