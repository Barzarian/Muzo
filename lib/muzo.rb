# frozen_string_literal: true

require_relative "errors"
require "net/http"
require "uri"
require "json"

module Muzo
  # This wraps ESPN's public "site" API. It's the same API that
  # espn.com/scores etc. actually uses under the hood - it's not
  # officially documented by ESPN, so endpoints could change or break
  # at any time. Nothing we can do about that, just something to know.
  #
  # Example:
  #   client = muzo::Client.new(sport: "football", league: "nfl")
  #   client.scoreboard
  #   client.news
  #   client.teams
  #   client.team("dal")
  #   client.standings
  #
  class Client
    BASE_URL = "https://site.api.espn.com/apis/site/v2/sports"

    # standings live on a slightly different host, ESPN is weird like that
    STANDINGS_BASE_URL = "https://site.web.api.espn.com/apis/v2/sports"

    attr_reader :sport, :league

    # sport/league examples:
    #   sport: "football", league: "nfl"
    #   sport: "basketball", league: "nba"
    #   sport: "baseball", league: "mlb"
    #   sport: "hockey", league: "nhl"
    #   sport: "soccer", league: "eng.1"   (premier league)
    def initialize(sport:, league:)
      @sport = sport
      @league = league
    end

    # Today's games / current scoreboard for the league.
    # You can pass a date like "20240115" to look up a specific day.
    def scoreboard(date: nil)
      params = date ? { dates: date } : {}
      get("#{BASE_URL}/#{sport}/#{league}/scoreboard", params)
    end

    # Latest news articles for the league.
    def news(limit: 10)
      get("#{BASE_URL}/#{sport}/#{league}/news", { limit: limit })
    end

    # All teams in the league.
    def teams
      get("#{BASE_URL}/#{sport}/#{league}/teams")
    end

    # Info for a single team. team_id can be the numeric ESPN id or
    # the team's abbreviation, e.g. "dal" for the Cowboys.
    def team(team_id)
      get("#{BASE_URL}/#{sport}/#{league}/teams/#{team_id}")
    end

    # League standings.
    def standings
      get("#{STANDINGS_BASE_URL}/#{sport}/#{league}/standings")
    end

    # Box score / play by play / etc for a specific game.
    # event_id comes from the "id" field of a game in #scoreboard.
    def summary(event_id)
      get("#{BASE_URL}/#{sport}/#{league}/summary", { event: event_id })
    end

    private

    # Does the actual HTTP call and JSON parsing. Kept private since
    # nobody outside this class should need to call it directly.
    def get(url, params = {})
      uri = URI.parse(url)
      uri.query = URI.encode_www_form(params) unless params.empty?

      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"
      request["Accept"] = "application/json, text/plain, */*"
      request["Referer"] = "https://www.espn.com/"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.request(request)
      end

      unless response.is_a?(Net::HTTPSuccess)
        raise Muzo::RequestError.new(
          "ESPN API returned #{response.code} for #{uri}",
          response.code.to_i
        )
      end

      JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise Muzo::ParseError, "Couldn't parse ESPN's response: #{e.message}"
    end
  end
end
