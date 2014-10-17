# encoding: utf-8

module BitBucket
  class Repos::PullRequests::Comments < API
    @version = '2.0'

    # Creates new Repos::PullRequests::Comments API
    def initialize(options = {})
      super(options)
    end

    # List comments on a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.comments.all 'user-name', 'repo-name', 'pull-request-id'
    #
    def list(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      response = get_request("/repositories/#{user}/#{repo.downcase}/pullrequests/#{pull_request_id}/comments")
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Gets a single comment
    #
    # = Examples
    #  @bitbucket = BitBucket.new
    #  @bitbucket.repos.pull_requests.comments.get 'user-name', 'repo-name', 'pull-request-id')
    #
    def get(user_name, repo_name, pull_request_id, comment_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id
      _validate_presence_of comment_id

      get_request("/repositories/#{user}/#{repo.downcase}/pullrequests/#{pull_request_id}/comments/#{comment_id}")
    end
    alias :find :get
  end
end
