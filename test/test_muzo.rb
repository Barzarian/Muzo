# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/muzo"

# NOTE: these are just quick sanity checks I wrote while building this.
# They hit the real ESPN API, so they need internet access to pass.
# If I had more time I'd stub these out with webmock instead of making
# real network calls, but this was good enough to check things worked.
class ClientTest < Minitest::Test
  def setup
    @client = Muzo::Client.new(sport: "football", league: "nfl")
  end

  def test_initializes_with_sport_and_league
    assert_equal "football", @client.sport
    assert_equal "nfl", @client.league
  end

  def test_scoreboard_returns_a_hash
    result = @client.scoreboard
    assert_kind_of Hash, result
  end

  def test_teams_returns_a_hash
    result = @client.teams
    assert_kind_of Hash, result
  end

  def test_bad_league_raises_request_error
    bad_client = Muzo::Client.new(sport: "football", league: "not_a_real_league")

    assert_raises(Muzo::RequestError) do
      bad_client.scoreboard
    end
  end
end
