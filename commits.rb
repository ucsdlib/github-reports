#!/usr/bin/env ruby

require 'octokit'
require 'byebug'
require 'yaml'
require 'English'
require 'time'
require 'fileutils'

# expect start and end date parameters
start_date = Time.parse(ARGV[0])
end_date = Time.parse(ARGV[1])

unless start_date && end_date
  raise 'Please supply both a start and end date for the report..'
end

config = YAML.safe_load(File.read('config.yml'))
client = Octokit::Client.new(login: config['account']['user'],
                             password: config['account']['password'])
client.login
client.auto_paginate = true

report = File.open("commits-#{ARGV[0]}-#{ARGV[1]}.report", 'w')

organizations = ['ucsdlib']
# organizations = config['github']['community_organizations']

organizations.each do |org|
  # get changed repos within current date range
  org_repos = client.org_repos(org).select { |i| i[:pushed_at] >= start_date }.map do |repo|
    { url: repo[:clone_url].gsub('//', "//#{config['account']['user']}:#{config['account']['password']}@"), name: repo[:name] }
  end

  next unless org_repos
  tmp_dir = File.join('/tmp/',"#{ARGV[0]}-#{ARGV[1]}")
  FileUtils.mkdir(tmp_dir)
  begin
    org_repos.each do |repo|
      tmp_repo_path = "#{tmp_dir}/#{repo[:name]}"
      `git clone --bare --quiet #{repo[:url]} #{tmp_repo_path}`
      FileUtils.cd(tmp_repo_path) do
        commits = `git log --oneline --since="#{ARGV[0]}" --until="#{ARGV[1]}" | wc -l`
        report.puts "#{repo[:name]} #{commits}" if commits.to_i > 0
      end
    end
  rescue
    # .. handle error
  ensure
    FileUtils.remove_dir(tmp_dir, true)
  end
end

report.close
