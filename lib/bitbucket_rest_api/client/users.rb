
# encoding: utf-8

module BitBucket
  class Client::Users < API

    require_all 'bitbucket_rest_api/client/users', 'account'

    @version = '1.0'

    namespace :account

  end # Client
end # BitBucket
