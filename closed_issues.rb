#!/usr/bin/env ruby

require 'English'
require 'byebug'
require 'date'
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

config = YAML.safe_load(File.read('config.yml'))
client = Octokit::Client.new(login: config['account']['user'],
                             password: config['account']['password'])
client.login
report = File.open("closed_issues_#{start_date}-#{end_date}.report", 'w')

organizations = config['github']['community_organizations']
team = config['github']['team']
closed_date_range = "#{start_date}..#{end_date}"

report.puts "h1. Issues Closed Between: #{start_date} #{end_date}"
report.puts 'h2. Community/Open Source Issues'
report.puts '??Includes Issues and Pull Requests??'
report.puts '||Organization||Project||Issue/Pull Request||Assignee||'
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
  results = client.search_issues("org:#{config['github']['local_organization']} assignee:#{member} closed:#{closed_date_range}")
  results[:items].each do |issue|
    project = issue[:repository_url].rpartition('/').last
    report.puts "| #{project} | [#{issue[:title]}|#{issue[:html_url]}] | #{member} |"
  end
end

report.close
