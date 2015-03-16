# encoding: utf-8

module BitBucket
  class Client < API

    require_all 'bitbucket_rest_api/client',
      'issues',
      'repos',
      'users',
      'invitations'

    require_all 'bitbucket_rest_api/client/users', 'account'

    namespace :issues

    namespace :pull_requests

    namespace :repos
    alias :repositories :repos

    # Many of the resources on the users API provide a shortcut for getting
    # information about the currently authenticated user.
    namespace :users

    namespace :user
    alias :user_api :user

    namespace :invitations

    # This is a read-only API to the BitBucket events.
    # These events power the various activity streams on the site.
    def events(options = {})
      raise "Unimplemented"
      #@events ||= Api::Factory.new 'Events', options
    end

    # An API for users to manage their own tokens.
    def oauth(options = {})
      raise "Unimpletmented"
      #@oauth ||= Api::Factory.new 'Authorizations', options
    end
    alias :authorizations :oauth

    def teams(options = {})
      raise "Unimplemented"
      #@teams ||= Api::Factory.new 'teams', options
    end

    def search(options = {})
      raise "Unimplemented"
      #@search ||= Api::Factory.new 'Search', options
    end
  end # Client
end # BitBucket
