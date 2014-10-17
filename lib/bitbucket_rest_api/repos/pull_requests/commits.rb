# encoding: utf-8

module BitBucket
  class Repos::PullRequests::Commits < API
    @version = '2.0'

    # Creates new Repos::PullRequests::Commits API
    def initialize(options = {})
      super(options)
    end

    # List commits on a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.commits.all 'user-name', 'repo-name', 'pull-request-id'
    #
    def list(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      response = get_request("/repositories/#{user}/#{repo.downcase}/pullrequests/#{pull_request_id}/commits")
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list
  end
end
