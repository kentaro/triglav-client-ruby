require 'json'
require 'net/http'

require 'triglav/client/version'

module Triglav
  class Client
    class Error < StandardError; end

    attr_accessor :base_url, :api_token

    def initialize(args)
      @base_url  = args[:base_url]
      @api_token = args[:api_token]

      if !@base_url || !@api_token
        raise ArgumentError.new("Both `base_url` and `api_token` are required.")
      end
    end

    API_ENDPOINT_MAP = {
      services: { method: :get, path: '/api/services.json'            },
      roles:    { method: :get, path: '/api/roles.json'               },
      roles_in: { method: :get, path: ['/api/services/%s/roles.json'] },
      hosts:    { method: :get, path: '/api/hosts.json'               },
      hosts_in: {
        method: :get,
        path: [
          '/api/services/%s/hosts.json',
          '/api/services/%s/roles/%s/hosts.json',
        ]
      },
    }

    def endpoint_for (type, *args)
      endpoint = API_ENDPOINT_MAP[type]

      if args.empty?
        endpoint
      else
        path = endpoint[:path][args.size - 1]

        {
          method: endpoint[:method],
          path:   path % args,
        }
      end
    end

    def services
      endpoint = endpoint_for(:services)
      response = dispatch_request(endpoint[])
      response.map { |e| e['service'] }
    end

    def roles
      response = dispatch_request(endpoint_for(:roles))
      response.map { |e| e['role'] }
    end

    def roles_in (service)
      response = dispatch_request(endpoint_for(:roles_in, service))
      response.map { |e| e['role'] }
    end

    def hosts (options = {})
      response = dispatch_request(endpoint_for(:hosts))
      response.map { |e| e['host'] }.select do |h|
        if options[:with_inactive]
          true
        else
          h['active']
        end
      end
    end

    def hosts_in (service, role = nil, options = {})
      if role.is_a?(Hash)
        raise ArgumentError.new(
          "`role` must be passed (even if it's nil) when you want to pass `options`."
        )
      end

      if (role)
        response = dispatch_request(:hosts_in, service, role)
      else
        response = dispatch_request(hosts_in, service)
      end

      response.map { |e| e['host'] }.select do |h|
        if options[:with_inactive]
          true
        else
          h['active']
        end
      end
    end

    def dispatch_request(method, path, params = {})
      if !method || !path
        raise ArgumentError.new("Both `method` and `path` are required.")
      end

      json = do_request(method.to_s, path, params)
      JSON.parse(json)
    end

    private

    def do_request(method, path, params = {})
      uri = URI.parse(base_url)
      uri.path  = path

      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.__send__(method, "#{uri.path}?api_token=#{api_token}")
      end

      if response.code.to_i >= 300
        raise Error.new("#{response.code}: #{response.message}")
      end

      response.body
    end
  end
end
