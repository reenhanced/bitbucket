# encoding: utf-8

module BitBucket
  class PullRequests::Activity < API
    # Creates new PullRequests::Activity API
    def initialize(options = {})
      super(options)
    end

    # Get the activity for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.activity 'user-name', 'repo-name', 'pull-request-id'
    #
    def list(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      get_request("/repositories/#{user}/#{repo}/pull_requests/#{pull_request_id}/activity")
    end
    alias :all :list
  end
end
