require 'octokit'

module GitHub

  # Authenticated Octokit
  def github_client
    @github_client ||= Octokit::Client.new(access_token: @settings[:gh_access_token], auto_paginate: true)
  end

  # Return an Octokit GitHub Issue
  def issue
    @issue ||= github_client.issue(context.repo, context.issue_id)
  end

  # Post messages to a GitHub issue.
  # Context is an OpenStruct created in lib/github_webhook_parser
  def bg_respond(comment)
    github_client.add_comment(context.repo, context.issue_id, comment)
  end

  # Add labels to a GitHub issue
  # Context is an OpenStruct created in lib/github_webhook_parser
  def label_issue(labels)
    github_client.add_labels_to_an_issue(context.repo, context.issue_id, labels)
  end

  # Update a Github issue
  # Context is an OpenStruct created in lib/github_webhook_parser
  def update_issue(options)
    github_client.update_issue(context.repo, context.issue_id, options)
  end

  # Add a user as collaborator to the repo
  # Context is an OpenStruct created in lib/github_webhook_parser
  def add_collaborator(username)
    username = username.sub(/^@/, "").downcase
    github_client.add_collaborator(context.repo, username)
  end

  # Remove a user from repo's collaborators
  # Context is an OpenStruct created in lib/github_webhook_parser
  def remove_collaborator(username)
    username = username.sub(/^@/, "").downcase
    github_client.remove_collaborator(context.repo, username)
  end

  # Uses the GitHub API to determine if a user is already a collaborator of the repo
  # Context is an OpenStruct created in lib/github_webhook_parser
  def is_collaborator?(username)
    username = username.sub(/^@/, "").downcase
    github_client.collaborator?(context.repo, username)
  end

  # Uses the GitHub API to determine if a user has a pending invitation
  # Context is an OpenStruct created in lib/github_webhook_parser
  def is_invited?(username)
    username = username.sub(/^@/, "").downcase
    github_client.repository_invitations(context.repo).any? { |i| i.invitee.login.downcase == username }
  end

  # Uses the GitHub API to obtain the id of an organization's team
  def team_id(org_name, team_name)
    begin
      team = github_client.organization_teams(org_name).select { |t| t[:slug] == team_name || t[:name].downcase == team_name.downcase }.first
      team.nil? ? nil : team[:id]
    rescue Octokit::Forbidden
      nil
    end
  end

  # Returns true if the user in a team member of any of the authorized teams
  # false otherwise
  def user_authorized?(user_login)
    @user_authorized ||= begin
      autorized = []
      authorized_team_ids.each do |team_id|
        autorized << github_client.team_member?(team_id, user_login)
        break if autorized.compact.any?
      end
      autorized.compact.any?
    end
  end

  # The url of the invitations page for the current repo
  def invitations_url
    "https://github.com/#{context.repo}/invitations"
  end

end