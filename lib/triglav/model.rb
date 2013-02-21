require 'ostruct'

module Triglav
  module Model
    module Base
      attr_reader :client, :info

      def initialize(args)
        @client = args[:client]
        @info   = OpenStruct.new(args[:info])
      end

      def path
        self.class.to_s.split('::').last.downcase + 's'
      end

      def show
        client.dispatch_request('get', "/api/#{path}/#{info.name}.json")
      end

      def update(params = {})
        client.dispatch_request('put', "/api/#{path}/#{info.name}.json", params)
      end

      def destroy
        client.dispatch_request('delete', "/api/#{path}/#{info.name}.json")
      end

      def revert
        client.dispatch_request('put', "/api/#{path}/#{info.name}/revert.json")
      end
    end

    class Service
      include Base
    end

    class Role
      include Base
    end

    class Host
      include Base
    end
  end
end
