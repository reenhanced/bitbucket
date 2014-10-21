# encoding: utf-8

require 'bitbucket_rest_api/response'
require 'bitbucket_rest_api/response/mashify'
require 'bitbucket_rest_api/response/jsonize'
require 'bitbucket_rest_api/response/raise_error'
require 'bitbucket_rest_api/response/header'

module BitBucket
  class Middleware
    def self.default(options = {})
      api     = options[:api]
      adapter = options[:adapter]
      proc do |builder|
        builder.use Faraday::Request::Multipart
        builder.use Faraday::Request::UrlEncoded
        builder.use FaradayMiddleware::OAuth, {:consumer_key => client_id, :consumer_secret => client_secret, :token => oauth_token, :token_secret => oauth_secret} if client_id? and client_secret?
        builder.use BitBucket::Request::BasicAuth, authentication if basic_authed?
        builder.use FaradayMiddleware::EncodeJson

        builder.use Faraday::Response::Logger if ENV['DEBUG']
        builder.use BitBucket::Response::Helpers
        unless options[:raw]
          builder.use BitBucket::Response::Mashify
          builder.use BitBucket::Response::Jsonize
        end
        builder.use BitBucket::Response::RaiseError
        builder.adapter adapter
      end
    end
  end # Middleware
end # BitBucket
