module BitBucket
  module Constants
    extend self

    # Response headers
    RATELIMIT_REMAINING = 'X-RateLimit-Remaining'.freeze

    RATELIMIT_LIMIT = 'X-RateLimit-Limit'.freeze

    CONTENT_TYPE = 'Content-Type'.freeze

    CONTENT_LENGTH = 'content-length'.freeze

    CACHE_CONTROL = 'cache-control'.freeze

    ETAG = 'ETag'.freeze

    SERVER = 'Server'.freeze

    DATE = 'Date'.freeze

    LOCATION = 'Location'.freeze

    USER_AGENT = 'User-Agent'.freeze

    ACCEPT = 'Accept'.freeze

    ACCEPT_CHARSET = 'Accept-Charset'.freeze

    # Link params
    META_REL = "rel".freeze

    META_LAST = "last".freeze

    META_NEXT = "next".freeze

    META_FIRST = "first".freeze

    META_PREV = "prev".freeze

    PARAM_PAGE = "page".freeze

    PARAM_START_PAGE = "start_page".freeze

    # URI parsing
    QUERY_STR_SEP = '?'.freeze


  end # Constants
end # BitBucket
