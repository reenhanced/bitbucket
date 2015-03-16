# encoding: utf-8

require 'faraday'
require 'faraday_middleware'
require 'bitbucket_rest_api/version'
require 'bitbucket_rest_api/configuration'
require 'bitbucket_rest_api/constants'
require 'bitbucket_rest_api/utils/url'
require 'bitbucket_rest_api/connection'
require 'bitbucket_rest_api/deprecation'
require 'bitbucket_rest_api/core_ext/ordered_hash'
require 'bitbucket_rest_api/ext/faraday'
require 'bitbucket_rest_api/middleware'

module BitBucket
  LIBNAME = 'bitbucket_rest_api'

  LIBDIR = File.expand_path("../#{LIBNAME}", __FILE__)

  class << self
    def included(base)
      base.extend ClassMethods
    end

    # Handle for the client instance
    attr_accessor :api_client

    # Alias for BitBucket::Client.new
    #
    # @return [BitBucket::Client]
    def new(options = { }, &block)
      @api_client = Client.new(options, &block)
    end

    # Default middleware stack that uses default adapter as specified
    # by configuration setup
    #
    # @return [Proc]
    #
    # @api private
    def default_middleware(options = {})
      Middleware.default(options)
    end

    # Delegate to BitBucket::Client
    #
    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end

  end

  module ClassMethods

    # Requires internal libraries
    #
    # @param [String] prefix
    #   the relative path prefix
    # @param [Array[String]] libs
    #   the array of libraries to require
    #
    # @return [self]
    def require_all(prefix, *libs)
      libs.each do |lib|
        require "#{File.join(prefix, lib)}"
      end
    end

    # The client configuration
    #
    # @return [Configuration]
    #
    # @api public
    def configuration
      @configuration ||= Configuration.new
    end

    # Configure options
    #
    # @example
    #   BitBucket.configure do |c|
    #     c.some_option = true
    #   end
    #
    # @yield the configuration block
    # @yieldparam configuration [BitBucket::Configuration]
    #   the configuration instance
    #
    # @return [nil]
    #
    # @api public
    def configure
      yield configuration
    end
  end

  extend ClassMethods

  require_all LIBDIR,
    'authorization',
    'validations',
    'normalizer',
    'parameter_filter',
    'api',
    'client',
    'pagination',
    'request',
    'response',
    'response_wrapper',
    #'result',
    'error',
    'page_links',
    'paged_request',
    'page_iterator',
    'params_hash'

    #'repos',
    #'issues',
    #'user',
    #'users',
    #'invitations',
    #'page_links',
    #'paged_request',
    #'page_iterator'

    #'teams',
    #'users',
    #'events',
    #'search',

end # BitBucket
