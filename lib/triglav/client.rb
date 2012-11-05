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

    def services
      response = dispatch_request('get', '/api/services.json')
      response.map { |e| e['service'] }
    end

    def roles
      response = dispatch_request('get', '/api/roles.json')
      response.map { |e| e['role'] }
    end

    def roles_in (service)
      response = dispatch_request('get', "/api/services/#{service}/roles.json")
      response.map { |e| e['role'] }
    end

    def hosts (options = {})
      response = dispatch_request('get', '/api/hosts.json')
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
        response = dispatch_request('get', "/api/services/#{service}/roles/#{role}/hosts.json")
      else
        response = dispatch_request('get', "/api/services/#{service}/hosts.json")
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

      json = do_request(method, path, params)
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
