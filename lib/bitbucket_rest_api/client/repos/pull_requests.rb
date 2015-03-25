# encoding: utf-8

module BitBucket
  class Client::Repos::PullRequests < API

    # Load all the modules after initializing Repos to avoid superclass mismatch
    require_all 'bitbucket_rest_api/client/repos/pull_requests',
      'comments',
      'commits'

    REQUIRED_PULL_REQUEST_OPTIONS = %w[
      title
      source
    ]

    VALID_PULL_REQUEST_PARAM_NAMES = %w[
      title
      description
      source
      destination
      reviewers
      close_source_branch
    ].freeze

    VALID_PULL_REQUEST_STATE_VALUES = {
      state: ['OPEN', 'MERGED', 'DECLINED']
    }

    @version = '2.0'

    # Access to Client::Repos::PullRequests::Comments API
    namespace :comments
    namespace :commits

    # List pull requests for a repository
    #
    # = Inputs
    #  <tt>:state</tt> - Optional - State of the pull request (OPEN, MERGED, DECLINED)
    #
    def list(*args)
      arguments(args, required: [:user, :repo], optional: [:state])
      params = arguments.params
      user   = arguments.user
      repo   = arguments.repo

      params['state'] ||= 'OPEN'
      # Bitbucket requires the state to be all caps or it returns all
      params['state']   = params['state'].upcase

      response = get_request("/repositories/#{user}/#{repo}/pullrequests/", params)

      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Get a single pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.find 'user-name', 'repo-name', 'pull-request-id'
    #
    def get(*args)
      arguments(args, required: [:user, :repo, :pull_request_id])

      get_request("/repositories/#{arguments.user}/#{arguments.repo.downcase}/pullrequests/#{arguments.pull_request_id}", arguments.params)
    end

    alias :find :get

    # Create a pull request
    #
    # = Inputs
    #  <tt>:title</tt> - Required string
    #  <tt>:description</tt> - Optional string
    #  <tt>:source</tt> - Required hash - The source branch name and/or repository (for example, { develop)
    #  * <tt>{ "branch": { "name": "REQUIRED branch_name" }, "repository": { "full_name": "owner/repo_slug" } }</tt>
    #  <tt>:destination</tt> - Optional hash - The destination branch or commit
    #  * <tt>{ "branch": { "name": "branch_name" }, "commit": { "hash": "name" } }</tt>
    #  <tt>:reviewers</tt> - Optional array - Users currently reviewiing the pull
    #  * <tt>[{ "username": "accountname" }]</tt>
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.create 'user-name', 'repo-name',
    #    "title" => "Fixes a bug",
    #    "description" => "Fixes not being able to see anything.",
    #    "source" => { "branch" => { "name" => "bug-fixes" } },
    #    "destination" => { "branch" => { "name" => "master" } },
    #    "reviewers" => [ { "username" => "octocat" } ],
    #    "close_source_branch" => true
    #
    def create(*args)
      arguments(args, required: [:user, :repo]) do
        permit VALID_PULL_REQUEST_PARAM_NAMES
        assert_required REQUIRED_PULL_REQUEST_OPTIONS
      end

      post_request("/repositories/#{arguments.user}/#{arguments.repo.downcase}/pullrequests", arguments.params)
    end

    # Edit a pull request
    #
    # = Inputs
    #  <tt>:title</tt> - Required string
    #  <tt>:description</tt> - Optional string
    #  <tt>:destination</tt> - Optional hash - The destination branch or commit
    #  * <tt>{ "branch": { "name": "branch_name" }, "commit": { "hash": "name" } }</tt>
    #  <tt>:reviewers</tt> - Optional array - Users currently reviewiing the pull
    #  * <tt>[{ "username": "accountname" }]</tt>
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.update 'user-name', 'repo-name', 'pull-request-id',
    #    "title" => "Fixes a bug",
    #    "description" => "Fixes not being able to see anything.",
    #    "destination" => { "branch" => { "name" => "master" } },
    #    "reviewers" => [ { "username" => "octocat" } ],
    #    "close_source_branch" => true
    #
    def update(*args)
      arguments(args, required: [:user, :repo, :pull_request_id]) do
        permit VALID_PULL_REQUEST_PARAM_NAMES
      end

      user            = arguments.user
      repo            = arguments.repo
      pull_request_id = arguments.pull_request_id

      # BitBucket will drop any data if it is not included, so we have to check for pre-existing data
      existing_pull = get(user, repo, pull_request_id)
      existing_pull_data = {
        'title' => existing_pull.title,
        'description' => existing_pull.description,
        'destination' => {
          'branch' => existing_pull.destination.branch
        },
        'reviewers' => existing_pull.reviewers,
        'close_source_branch' => existing_pull.close_source_branch
      }
      params = normalize!(existing_pull_data).merge!(normalize!(arguments.params))

      put_request("/repositories/#{user}/#{repo.downcase}/pullrequests/#{pull_request_id}/", params)
    end
    alias :edit :update

    # Decline or reject a single pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.reject 'user-name', 'repo-name', 'pull-request-id'
    #
    def decline(user_name, repo_name, pull_request_id)
      arguments(args, required: [:user, :repo, :pull_request_id])

      post_request("/repositories/#{arguments.user}/#{arguments.repo}/pullrequests/#{arguments.pull_request_id}/decline")
    end
    alias :reject :decline

    # Give approval on a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.approve 'user-name', 'repo-name', 'pull-request-id'
    #
    def approve(user_name, repo_name, pull_request_id)
      arguments(args, required: [:user, :repo, :pull_request_id])

      post_request("/repositories/#{arguments.user}/#{arguments.repo}/pullrequests/#{arguments.pull_request_id}/approve")
    end

    # Get the diff for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.diff 'user-name', 'repo-name', 'pull-request-id'
    #
    def diff(user_name, repo_name, pull_request_id)
      arguments(args, required: [:user, :repo, :pull_request_id])

      get_request("/repositories/#{arguments.user}/#{arguments.repo}/pullrequests/#{arguments.pull_request_id}/diff")
    end

    # Get a log of all activity for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.repos.pull_requests.activity 'user-name', 'repo-name'
    #
    def activity(*args)
      arguments(args, required: [:user, :repo, :pull_request_id])

      response = get_request("/repositories/#{arguments.user}/#{arguments.repo}/pullrequests/#{arguments.pull_request_id}/activity")

      return response unless block_given?
      response.each { |el| yield el }
    end
  end # Repos::PullRequests
end # BitBucket
