# Xporter
ruby gem for DSL creating streaming CSV exports.

[ ![Codeship Status for madebylotus/xporter](https://app.codeship.com/projects/3f5726f0-e48f-0136-991e-763ab7b07a90/status?branch=master)](https://app.codeship.com/projects/319101)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xporter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xporter

## Usage
In most cases, you'll use this library in a rails app, to organize different exporters and optionally use Live Streaming from the controller to browser to begin streaming results straight from the database to the client.

### Define Exporter
To define an exporter, simply place a file in the `app/exporters` directory in your rails app (restarting app server if creating directory for the first time).

```ruby
# app/exporters/admin_exporter.rb
class AdminExporter < Xporter::Exporter
  model User
  decorates AdminDecorator

  column(:name)
  column(:email)
  column(:dynamic) { |record| record.object_id }
end
```

### Generate CSV String
With an exporter defined, you'll want to convert a collection of objects into a CSV string.

```ruby
exporter = AdminExporter.new
exporter.generate(User.all)
# => "Name,Email,Dynamic\nJustin,justin@madebylotus.com,12345511\n"
```

If provided an `ActiveRecord::Relation`, we'll fetch records lazily in batches from ActiveRecord.

### Stream CSV to Browser
With an exporter defined, you'll want to convert a collection of objects and stream to the browser immediately.

```ruby
class AdministratorsController < ApplicationController
  include Xporter::FileStreamer

  def index
    @users = User.all

    respond_to do |format|
      format.html
      format.csv do
        stream_file "administrators-export-#{ SecureRandom.uuid }".parameterize, 'csv' do |stream|
          AdminExporter.stream(@users, stream)
        end
      end
    end
  end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/xporter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Xporter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/madebylotus/xporter/blob/master/CODE_OF_CONDUCT.md).
