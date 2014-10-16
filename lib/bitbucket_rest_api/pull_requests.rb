# encoding: utf-8

module BitBucket
  class PullRequests < API
    extend AutoloadHelper

    # Load all the modules after initializing Repos to avoid superclass mismatch
    autoload_all 'bitbucket_rest_api/pull_requests',
                 :Comments  => 'comments',
                 :Commits   => 'commits',
                 :Activity  => 'activity'

    VALID_PULL_REQUEST_PARAM_NAMES = %w[
      title
      description
      source
      destination
      reviewers
      close_source_branch
    ].freeze

    VALID_PULL_REQUEST_STATUS_VALUES = {
      'status' => ['OPEN', 'MERGED', 'DECLINED']
    }

    @version = '2.0'

    # Creates new PullRequests API
    def initialize(options = { })
      super(options)
    end

    # Access to PullRequests::Comments API
    def comments
      @comments ||= ApiFactory.new 'PullRequests::Comments'
    end

    # List pull requests for a repository
    #
    # = Inputs
    #  <tt>:state</tt> - Optional - State of the pull request (OPEN, MERGED, DECLINED)
    #
    def list(user_name, repo_name, params)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?

      normalize! params
      filter! ['status'], params
      assert_valid_values(VALID_PULL_REQUEST_STATUS_VALUES, params)

      response = get_request("/repositories/#{user}/#{repo.downcase}/pull_requests/", params)
      return response unless block_given?
      response.each { |el| yield el }
    end
    alias :all :list

    # Get a single pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.find 'user-name', 'repo-name', 'pull-request-id'
    #
    def get(user_name, repo_name, pull_request_id, params={ })
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      normalize! params

      get_request("/repositories/#{user}/#{repo.downcase}/pull_requests/#{pull_request_id}", params)
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
    #  bitbucket = BitBucket.new :user => 'user-name', :repo => 'repo-name'
    #  bitbucket.pull_requests.create
    #    "title" => "Fixes a bug",
    #    "description" => "Fixes not being able to see anything.",
    #    "source" => { "branch" => { "name" => "bug-fixes" } },
    #    "destination" => { "branch" => { "name" => "master" } },
    #    "reviewers" => [ { "username" => "octocat" } ],
    #    "close_source_branch" => true
    #
    def create(user_name, repo_name, params={})
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?

      normalize! params
      filter! VALID_PULL_REQUEST_PARAM_NAMES , params
      assert_required_keys(%w[ title source ], params)

      post_request("/repositories/#{user}/#{repo.downcase}/pull_requests/", params)
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
    #  bitbucket.pull_requests.update 'user-name', 'repo-name', 'pull-request-id',
    #    "title" => "Fixes a bug",
    #    "description" => "Fixes not being able to see anything.",
    #    "destination" => { "branch" => { "name" => "master" } },
    #    "reviewers" => [ { "username" => "octocat" } ],
    #    "close_source_branch" => true
    #
    def update(user_name, repo_name, pull_request_id, params={})
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      # BitBucket will drop any data if it is not included, so we have to check for pre-existing data
      existing_pull = get(user_name, repo_name, pull_request_id)
      existing_pull_data = {
        'title' => existing_pull.title,
        'description' => existing_pull.description,
        'destination' => {
          'branch' => existing_pull.destination.branch
        },
        'reviewers' => existing_pull.reviewers,
        'close_source_branch' => existing_pull.close_source_branch
      }

      normalize! params
      params.merge! normalize!(existing_pull_data)
      filter! VALID_PULL_REQUEST_PARAM_NAMES.reject{|param| param == 'source'}, params
      assert_required_keys(%w[ title ], params)

      put_request("/repositories/#{user}/#{repo.downcase}/pull_requests/#{pull_request_id}")
    end
    alias :edit :update

    # Decline or reject a single pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.reject 'user-name', 'repo-name', 'pull-request-id'
    #
    def decline(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      post_request("/repositories/#{user}/#{repo}/pull_requests/#{pull_request_id}/decline")
    end
    alias :reject :decline

    # Give approval on a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.approve 'user-name', 'repo-name', 'pull-request-id'
    #
    def approve(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      post_request("/repositories/#{user}/#{repo}/pull_requests/#{pull_request_id}/approve")
    end

    # Get the diff for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.diff 'user-name', 'repo-name', 'pull-request-id'
    #
    def diff(user_name, repo_name, pull_request_id)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of pull_request_id

      get_request("/repositories/#{user}/#{repo}/pull_requests/#{pull_request_id}/diff")
    end

    # Get a log of all activity for a pull request
    #
    # = Examples
    #  bitbucket = BitBucket.new
    #  bitbucket.pull_requests.activity 'user-name', 'repo-name'
    #
    def activity(user_name, repo_name)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?

      get_request("/repositories/#{user}/#{repo}/pull_requests/activity")
    end
  end # PullRequests
end # BitBucket
