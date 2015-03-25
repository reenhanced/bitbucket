# encoding: utf-8

module BitBucket
  class Client::Repos::PullRequests::Comments < API
    @version = '2.0'

    # List comments on a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.comments.all 'user-name', 'repo-name', 'pull-request-id'
    #
    def list(*args)
      arguments(args, required: [:user, :repo, :pull_request_id])
      user            = arguments.user
      repo            = arguments.repo
      pull_request_id = arguments.pull_request_id

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
    def get(*args)
      arguments(args, required: [:user, :repo, :pull_request_id, :comment_id])
      user            = arguments.user
      repo            = arguments.repo
      pull_request_id = arguments.pull_request_id
      comment_id      = arguments.comment_id

      get_request("/repositories/#{user}/#{repo.downcase}/pullrequests/#{pull_request_id}/comments/#{comment_id}")
    end
    alias :find :get
  end
end
