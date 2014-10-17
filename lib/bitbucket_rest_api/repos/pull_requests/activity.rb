# encoding: utf-8

module BitBucket
  class Repos::PullRequests::Activity < API
    @version = '2.0'

    # Creates new Repos::PullRequests::Activity API
    def initialize(options = {})
      super(options)
    end

    # Get the activity for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.activity 'user-name', 'repo-name', 'pull-request-id'
    #
    def list(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      get_request("/repositories/#{user}/#{repo}/pullrequests/#{pull_request_id}/activity")
    end
    alias :all :list
  end
end
