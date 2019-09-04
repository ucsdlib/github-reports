#!/usr/bin/env ruby

require 'English'
require 'byebug'
require 'date'
require 'gitlab'
require 'octokit'
require 'yaml'

# expect start and end date parameters
start_date = ARGV[0]
end_date = ARGV[1]

unless start_date && end_date
  raise 'Please supply both a start and end date for the report..'
end

# simple date validation
begin
  [start_date, end_date].each do |d|
    Date.parse(d)
  end
end

report = File.open("closed_issues_#{start_date}-#{end_date}.report", 'w')
config = YAML.safe_load(File.read('config.yml'))

# setup Gitlab creds
Gitlab.endpoint = config.dig("gitlab", "endpoint")
Gitlab.private_token = config.dig("gitlab", "personal_access_token")
# set longer read timeout, Gitlab sometimes stalls
# see: https://github.com/NARKOZ/gitlab/issues/357
ENV['GITLAB_API_HTTPARTY_OPTIONS'] = "{read_timeout: 60}"

# Gitlab Closed Issues
gitlab_projects = config.dig("gitlab", "projects")
gitlab_team = config.dig("gitlab", "team")
report.puts "h1. Issues Closed Between: #{start_date} #{end_date}"
report.puts 'h2. Community/Open Source Issues'
report.puts '??Includes Issues??'
report.puts '||Organization||Project||Issue/Pull Request||Assignee||'
gitlab_projects.product(gitlab_team).each do |project, member|
  Gitlab.issues(project, state: 'closed', assignee_username: member).auto_paginate do |issue|
    # TODO: this is not efficient, but the API doesn't seem to support querying against date ranges
    if Date.parse(issue.closed_at).between?(Date.parse(start_date), Date.parse(end_date))
      report.puts "| #{project.split('/').first} | #{project} | [#{issue.title}|#{issue.web_url}] | #{member} |"
    end
  end
end

client = Octokit::Client.new(login: config.dig('account', 'user'),
                             password: config.dig('account', 'password'))
client.login
client.auto_paginate = true

organizations = config.dig('github', 'community_organizations')
team = config.dig('github', 'team')
closed_date_range = "#{start_date}..#{end_date}"

# community issues
organizations.product(team).each do |org, member|
  results = client.search_issues("org:#{org} assignee:#{member} closed:#{closed_date_range}")
  results[:items].each do |issue|
    project = issue[:repository_url].rpartition('/').last
    report.puts "| #{org} | #{project} | [#{issue[:title]}|#{issue[:html_url]}] | #{member} |"
  end
end

# local/ucsd issues
report.puts 'h2. UCSD Issues'
report.puts '??Includes Issues and Pull Requests??'
report.puts '||Project||Issue/Pull Request||Assignee||'
team.each do |member|
  results = client.search_issues("org:#{config.dig('github', 'local_organization')} assignee:#{member} closed:#{closed_date_range}")
  results[:items].each do |issue|
    project = issue[:repository_url].rpartition('/').last
    report.puts "| #{project} | [#{issue[:title]}|#{issue[:html_url]}] | #{member} |"
  end
end

report.close
