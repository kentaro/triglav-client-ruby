# Triglav::Client [![BuildStatus](https://secure.travis-ci.org/kentaro/triglav-client-ruby.png)](http://travis-ci.org/kentaro/triglav-client-ruby)

Triglav::Client is a Ruby interface to [Triglav](http://github.com/kentaro/triglav) API.

## Synopsis

```ruby
require 'triglav/client'

client = Triglav::Client.new(
  base_url:  'http://example.com/',  # Base URL which your Triglav is located at
  api_token: 'xxxxxxxxxxxxxxxxxxx'   # You can get it from your page on Triglav
)

# Services
client.services                      #=> Returns all the services registered on Triglav

# Get service information
service = client.services.first      #=> Triglav::Model::Service instance
service.info.name                    #=> "sqale"

# Roles
client.roles                         #=> Returns all the roles registered on Triglav
client.roles_in('sqale')             #=> Only roles in the service

# Get role information
role = client.roles_in('sqale').first   #=> Triglav::Model::Role instance
role.info.name                          #=> "app"

# Active hosts (default behaviour)
client.hosts                         #=> Returns all the hosts registered on Triglav
client.hosts_in('sqale')             #=> Only hosts in the service
client.hosts_in('sqale', 'users')    #=> Only hosts in the service and which have the role

# All hosts including inactive ones
client.hosts(with_inactive: true)
client.hosts_in('sqale',     nil, with_inactive: true)
client.hosts_in('sqale', 'users', with_inactive: true)

# Get host information
host = client.hosts_in('sqale').first   #=> Triglav::Model::Host instance
host.info.name                          #=> "app001.sqale.jp"
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
