# Triglav::Client [![BuildStatus](https://secure.travis-ci.org/kentaro/triglav-client.png)](http://travis-ci.org/kentaro/triglav-client)

Triglav::Client is a Ruby interface to [Triglav](http://github.com/kentaro/triglav) API.

## Synopsis

```ruby
require 'triglav/client'

client = Triglav::Client.new(
  base_url:  'http://example.com/',  # Base URL which your Triglav is located at
  api_token: 'xxxxxxxxxx'            # You can get it from your page on Triglav
)

# Services
client.services #=> Returns all the services registered on Triglav

# Roles
client.roles    #=> Returns all the roles registered on Triglav
client.roles_in('service') #=> Only roles in the service

# Active Hosts (default behaviour)
client.hosts    #=> Returns all the hosts registered on Triglav
client.hosts_in('service')         #=> Only hosts in the service
client.hosts_in('service', 'role') #=> Only hosts in the service and which have the role

# Inactive Hosts
client.hosts(with_inactive: true)
client.hosts_in('service', nil, with_inactive: true)
client.hosts_in('service', 'role', with_inactive: true)
```

## Installation

Add this line to your application's Gemfile:

    gem 'triglav-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install triglav-client

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
