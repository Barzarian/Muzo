## Muzo

A small Ruby gem for pulling data from ESPN's public API - scores, news,
teams, and standings.

Heads up: this isn't an *official* ESPN API. It's the same one that
powers espn.com, and ESPN doesn't publish docs for it, so endpoints
could change or go away without warning. Use accordingly.

## Installation

Add this to your Gemfile:

```ruby
gem "muzo"
```

Then run:

```
bundle install
```

Or install it by itself:

```
gem install muzo
```

## Usage

First, make a client for the sport/league you care about:

```ruby
require "muzo"

client = muzo::Client.new(sport: "football", league: "nfl")
```

Some other sport/league combos that work:

| sport        | league  | what it is          |
|--------------|---------|----------------------|
| football     | nfl     | NFL                  |
| basketball   | nba     | NBA                  |
| baseball     | mlb     | MLB                  |
| hockey       | nhl     | NHL                  |
| football     | college-football | NCAA football |
| basketball   | mens-college-basketball | NCAA men's basketball |
| soccer       | eng.1   | English Premier League |

### Scoreboard

```ruby
client.scoreboard
# => games happening today (or the current "slate")

client.scoreboard(date: "20240115")
# => games on a specific day (YYYYMMDD)
```

### News

```ruby
client.news
client.news(limit: 5)
```

### Teams

```ruby
client.teams
# => every team in the league

client.team("dal")
# => just the Cowboys (works with abbreviation or ESPN's numeric id)
```

### Standings

```ruby
client.standings
```

### Game summary (box score, play-by-play, etc)

```ruby
scoreboard = client.scoreboard
event_id = scoreboard["events"].first["id"]

client.summary(event_id)
```

## Error handling

Every request can raise one of:

- `muzo::RequestError` - ESPN responded with a non-2xx status.
  Has a `status_code` you can check.
- `muzo::ParseError` - the response body wasn't valid JSON.

Both are subclasses of `muzo::Error`, so you can just rescue that
if you don't care about the difference:

```ruby
begin
  client.scoreboard
rescue muzo::Error => e
  puts "Something went wrong: #{e.message}"
end
```

## Running the tests

```
bundle install
rake test
```

(The tests hit the real ESPN API, so you'll need an internet
connection for them to pass.)

## Known limitations

- No authentication support - as far as I know these endpoints don't
  need it, but that also means no access to anything private.
- No retry/backoff logic if ESPN rate-limits you.
- Response shapes aren't wrapped in nice Ruby objects yet, you just
  get back the raw parsed JSON as a Hash. Might add that later.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Muzo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Barzarian/muzo/blob/master/CODE_OF_CONDUCT.md).
