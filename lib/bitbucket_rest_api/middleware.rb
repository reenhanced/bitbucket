# encoding: utf-8

require 'bitbucket_rest_api/response'
require 'bitbucket_rest_api/response/mashify'
require 'bitbucket_rest_api/response/jsonize'
require 'bitbucket_rest_api/response/raise_error'
require 'bitbucket_rest_api/response/header'

module BitBucket
  class Middleware
    def self.default(options = {})
      api = options[:api]
      proc do |builder|
        builder.use BitBucket::Request::Jsonize
        builder.use Faraday::Request::UrlEncoded
        builder.use Faraday::Request::Multipart
        builder.use BitBucket::Request::OAuth, {:consumer_key => api.client_id, :consumer_secret => api.client_secret, :token => api.oauth_token, :token_secret => api.oauth_secret} if api.client_id? and api.client_secret?
        builder.use BitBucket::Request::BasicAuth, api.authentication if api.basic_authed?

        builder.use Faraday::Response::Logger if ENV['DEBUG']
        #builder.use BitBucket::Response::Helpers
        unless options[:raw]
          builder.use BitBucket::Response::Mashify
          builder.use BitBucket::Response::Jsonize
        end
        builder.use BitBucket::Response::RaiseError
        builder.adapter options[:adapter]
      end
    end
  end # Middleware
end # BitBucket
