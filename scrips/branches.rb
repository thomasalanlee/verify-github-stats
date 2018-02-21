#!/usr/bin/env ruby

require 'octokit'

client = Octokit::Client.new(netrc: true, per_page:10)
client.login

repos = ['verify-hub', 'verify-matching-service-adapter', 'verify-frontend']

repos.each do |repo|
  puts "------------------ #{repo} ---------------------"

  pull_requests = client.pull_requests("alphagov/#{repo}", :state => 'all')

  pull_requests.each do |pr|
  commits = client.pull_request_commits("alphagov/#{repo}", pr.number)
  files_changed = client.pull_request_files("alphagov/#{repo}", pr.number).length
  puts "Pull request #{pr.number} contained #{commits.length} commits, modified #{files_changed} files and was raised by #{pr.user.login}"
  end

end
