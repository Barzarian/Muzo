# frozen_string_literal: true

module Muzo
  # Base error so people can rescue Muzo::Error and catch everything
  # this gem raises, without having to know about every subclass.
  class Error < StandardError; end

  # Raised when ESPN gives us back something that isn't a 2xx.
  class RequestError < Error
    attr_reader :status_code

    def initialize(message, status_code = nil)
      @status_code = status_code
      super(message)
    end
  end

  # Raised when we can't parse the JSON ESPN sent back.
  class ParseError < Error; end
end
