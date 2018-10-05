# Citadel

Citadel Ruby client is a gem to interact with Citadel infrastructure in your Ruby projects.
Citadel is a secured messaging app based on Matrix protocol.
This gem enables you to connect to your account and publish messages, it can also create rooms or invite people in rooms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'citadel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install citadel

## Usage

### Basics

First you must instanciate a client with a base url, which represents the tenant (or server) you'll log in to, and a limit for public rooms (default value is 100).

```require 'citadel'```

```client = Citadel::Client.new('https://myTenant.citadel.team/', 150)```


And then, you have to log in

```client.sign_in("@John.Doe:myTenant.citadel.team","password")```


You can now send a message! Use the id of a room you're in

```client.send_message("!123456789:myTenant.citadel.team","Hello world!")```


### List rooms

```client.list_all_public_rooms```
lists all public rooms in your tenant directory


```client.list_all_joined_rooms```
lists all rooms you're in

```client.set_public_rooms_limit(100)```
specifies a limit when fetching rooms in your tenant directory (usefull when you have many of them)


### Room creation

```client.create_room(room_name, topic)```
creates a room with name *room_name* and topic *topic*. Visibility is "public" by default.


### Invite other users
```client.invite_users_in_room(room_id, users)```
invites all users provided in array *users* in room of id *room_id*. You must use users's is (@name:tenant.citadel.team)

```client.invite_in_room(room_id, user_id)```
invite a single user in specified room. Use user id as above.


### Join or leave a room

```client.join_room(room_id)```
to join a room

```client.leave_room(room_id)```
to leave a room


### Room administration

```client.change_room_visibility(room_id, visibility)```
to change a room visibility. Visibility can be "private" or "public". It requires you to be admin of this room.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/claireduf/citadel. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Citadel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/citadel/blob/master/CODE_OF_CONDUCT.md).
