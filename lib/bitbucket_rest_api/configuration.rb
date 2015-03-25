# encoding: utf-8

require 'bitbucket_rest_api/api/config'

module BitBucket
  # Stores the configuration
  class Configuration < API::Config

    # Other adapters are :typhoeus, :patron, :em_synchrony, :excon, :test
    property :adapter, default: :net_http

    # By default, don't set an application key
    property :client_id, default: nil

    # By default, don't set an application secret
    property :client_secret, default: nil

    # By default, don't set a user oauth access token
    property :oauth_token, default: nil

    # By default, don't set a user oauth access token secret
    property :oauth_secret, default: nil

    # By default, don't set a user login name
    property :login, default: nil

    # By default, don't set a user password
    property :password, default: nil

    # By default, don't set a user basic authentication
    property :basic_auth, default: nil

    # The endpoint used to connect to BitBucket if none is set, in the event that BitBucket is ever available on location
    property :endpoint, default: 'https://bitbucket.org/api/1.0'.freeze
    property :endpoint_v2, default: 'https://api.bitbucket.org/2.0'.freeze

    # The value sent in the http header for 'User-Agent' if none is set
    property :user_agent, default: "BitBucket Ruby Gem #{BitBucket::VERSION::STRING}".freeze

    # By default the <tt>Accept</tt> header will make a request for <tt>JSON</tt>
    property :mime_type, default: :json

    # By default uses the Faraday connection options if none is set
    property :connection_options, default: { }

    # By default, don't set user name
    property :user, default: nil

    # By default, don't set repository name
    property :repo, default: nil

    # By default, don't auto-paginate results
    property :auto_pagination, default: false

    # Add Faraday::RackBuilder to overwrite middleware
    property :stack

  end # Configuration
end # BitBucket
