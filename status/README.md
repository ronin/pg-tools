# PgTools::Status

This is a minimal tool, written in pure Ruby, that checks if Postgres server is running and accepting connections. It may be quite useful as part of some automatic pipeline, like your Continuous Integration or Continuous Deployment. For example, when you run application tests using Docker Composer with separate container for Postgres, you can loop this script until Postgres container is ready, before executing your tests.

I am also using it to wait until Heroku Postgres addon is provisioned, so I can execute database seeding script.

## Installation

Just download the file somewhere.

## Usage

Single check, password and database name are optional.

```ruby
load "status.rb"

PgTools::Status.ready?(
  host: "localhost",
  port: 5432,
  user: "db-user",
  password: "db-password",
  database: "db-name"
)
```

Running in a loop

```ruby
load "status.rb"

60.times do
  exit(0) if PgTools::Status.ready?(host: "localhost", port: 5432, user: "postgres")

  sleep 1
end

puts "Postgres is not responding"
```

## Caveats

This tool was not tested on huge amount of Postgres configurations, setups etc., so it may not work for you. I've tested it locally with password-less, cleartext and md5 authentication methods. Feel free to open an issue with your configuration and I will try my best to add support for it.
