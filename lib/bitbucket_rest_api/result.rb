# encoding: utf-8

module BitBucket
  module Result
    include BitBucket::Constants
    include Pagination

    # TODO Add result counts method to check total items looking at result links

    def paginated?
      loaded? ? !@env[:body][PARAM_PAGE].nil? : false
    end

    def ratelimit_limit
      loaded? ? @env[:response_headers][RATELIMIT_LIMIT] : nil
    end

    def ratelimit_remaining
      loaded? ? @env[:response_headers][RATELIMIT_REMAINING] : nil
    end

    def cache_control
      loaded? ? @env[:response_headers][CACHE_CONTROL] : nil
    end

    def content_type
      loaded? ? @env[:response_headers][CONTENT_TYPE] : nil
    end

    def content_length
      loaded? ? @env[:response_headers][CONTENT_LENGTH] : nil
    end

    def etag
      loaded? ? @env[:response_headers][ETAG] : nil
    end

    def date
      loaded? ? @env[:response_headers][DATE] : nil
    end

    def location
      loaded? ? @env[:response_headers][LOCATION] : nil
    end

    def server
      loaded? ? @env[:response_headers][SERVER] : nil
    end

    def status
      loaded? ? @env[:status] : nil
    end

    def success?
      (200..299).include? status
    end

    # Returns raw body
    def body
      loaded? ? @env[:body] : nil
    end

    def loaded?
      !!@env
    end

  end # Result
end # BitBucket
