#!/usr/bin/env ruby

require 'octokit'
require 'byebug'
require 'yaml'
require 'English'

config = YAML.safe_load(File.read('config.yml'))
client = Octokit::Client.new(login: config['account']['user'],
                             password: config['account']['password'])
client.login
report = File.open('open_issues.confluence', 'w')

organizations = config['github']['community_organizations']
team = config['github']['team']
report.puts 'h2. Community/Open Source Issues'
report.puts '||Organization||Project||Issue||Assignee||'
# community issues
organizations.product(team).each do |org, member|
  results = client.search_issues("org:#{org} assignee:#{member} is:open")
  results[:items].each do |issue|
    project = issue[:repository_url].rpartition('/').last
    report.puts "| #{org} | #{project} | [#{issue[:title]}|#{issue[:html_url]}] | #{member} |"
  end
end

# local/ucsd issues
report.puts 'h2. UCSD Issues'
report.puts '||Project||Issue||Assignee||'
team.each do |member|
  results = client.search_issues("org:#{config['github']['local_organization']} assignee:#{member} is:open")
  results[:items].each do |issue|
    project = issue[:repository_url].rpartition('/').last
    report.puts "| #{project} | [#{issue[:title]}|#{issue[:html_url]}] | #{member} |"
  end
end

report.close
