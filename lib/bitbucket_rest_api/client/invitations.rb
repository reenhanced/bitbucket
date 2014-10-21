# encoding: utf-8

module BitBucket
  class Client::Invitations < API
    @version = '1.0'

    def invite(user_name, repo_name, emailaddress, perm)
      _update_user_repo_params(user_name, repo_name)
      _validate_user_repo_params(user, repo) unless user? && repo?
      _validate_presence_of emailaddress
      perm ||= "write"

      post_request("/invitations/#{user}/#{repo.downcase}/#{emailaddress}", permission: perm)
    end
  end
end
