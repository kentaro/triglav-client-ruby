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
      services: { method: :get, path: '/api/services'            },
      roles:    { method: :get, path: '/api/roles'               },
      roles_in: { method: :get, path: ['/api/services/%s/roles'] },
      hosts:    { method: :get, path: '/api/hosts'               },
      hosts_in: {
        method: :get,
        path: [
          '/api/services/%s/hosts',
          '/api/services/%s/roles/%s/hosts',
        ]
      },
    }

    def endpoint_for (type, *args)
      endpoint = API_ENDPOINT_MAP[type]

      unless endpoint
        raise ArgumentError.new("No endpoint found for #{type}")
      end

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

    def create (model, params)
      case model
        when :service; Model::Service.create(self, params)
        when :role;    Model::Role.create(self, params)
        when :host;    Model::Host.create(self, params)
        else raise ArgumentError.new("No such model for #{model}")
      end
    end

    def services
      endpoint = endpoint_for(:services)
      response = dispatch_request(endpoint[:method], endpoint[:path])
      response.map do |e|
        Model::Service.new(client: self, info: e['service'])
      end
    end

    def roles
      endpoint = endpoint_for(:roles)
      response = dispatch_request(endpoint[:method], endpoint[:path])
      response.map do |e|
        Model::Role.new(client: self, info: e['role'])
      end
    end

    def roles_in (service)
      endpoint = endpoint_for(:roles_in, service)
      response = dispatch_request(endpoint[:method], endpoint[:path])
      response.map do |e|
        Model::Role.new(client: self, info: e['role'])
      end
    end

    def hosts (options = {})
      endpoint = endpoint_for(:hosts)
      response = dispatch_request(endpoint[:method], endpoint[:path])
      response.map do |e|
        Model::Host.new(client: self, info: e['host'])
      end.select do |h|
        if options[:with_inactive]
          true
        else
          h.info.active
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
        endpoint = endpoint_for(:hosts_in, service, role)
        response = dispatch_request(endpoint[:method], endpoint[:path])
      else
        endpoint = endpoint_for(:hosts_in, service)
        response = dispatch_request(endpoint[:method], endpoint[:path])
      end

      response.map do |e|
        Model::Host.new(client: self, info: e['host'])
      end.select do |h|
        if options[:with_inactive]
          true
        else
          h.info.active
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
      path = "#{uri.path}?api_token=#{api_token}"

      req = case method
            when :get;    Net::HTTP::Get.new(path)
            when :post;   req = Net::HTTP::Post.new(path); req.set_form_data(params); req
            when :put;    req = Net::HTTP::Put.new(path); req.set_form_data(params); req
            when :delete; Net::HTTP::Delete.new(path)
            end

      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(req)
      end

      if response.code.to_i >= 300
        raise Error.new("#{response.code}: #{response.message}")
      end

      response.body
    end
  end
end
