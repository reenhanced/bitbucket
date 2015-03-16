# encoding: utf-8

module BitBucket
  class Client::Users < API
    @version = '1.0'

    require_all 'bitbucket_rest_api/users', 'account'


    # Creates new Users API
    def initialize(options = { })
      super(options)
    end

    # Access to Users::Account API
    namespace :account


  end # Users
end # BitBucket
