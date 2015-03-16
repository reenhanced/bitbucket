# encoding: utf-8

module BitBucket
  module Connection
    extend self
    include BitBucket::Constants

    ALLOWED_OPTIONS = [
        :headers,
        :url,
        :params,
        :request,
        :ssl,
        :builder,
        :api
    ].freeze

    def default_options(options={})
      {
          :headers => {
              USER_AGENT       => options[:user_agent]
          },
          :ssl => { :verify => false },
          :url => options.fetch(:endpoint) { BitBucket.endpoint }
      }.merge(options)
    end

    def clear_cache
      @connection = nil
    end

    def caching?
      !@connection.nil?
    end

    # Exposes middleware builder to facilitate custom stacks and easy
    # addition of new extensions such as cache adapter.
    #
    def stack(options={})
      @stack ||= begin
        builder_class = defined?(Faraday::RackBuilder) ? Faraday::RackBuilder : Faraday::Builder
        builder_class.new(&BitBucket.default_middleware(options))
      end
    end

    # Returns a Fraday::Connection object
    #
    def connection(api, options = {})
      connection_options = default_options(options)
      clear_cache unless options.empty?
      builder = api.stack ? api.stack : stack(options.merge!(api: api))
      connection_options.merge!(builder: builder)
      connection_options.keep_if {|key, value| ALLOWED_OPTIONS.include?(key) }

      puts "OPTIONS:#{connection_options.inspect}" if ENV['DEBUG']

      @connection ||= Faraday.new(connection_options)
    end

  end # Connection
end # BitBucket
