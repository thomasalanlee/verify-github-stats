#!/usr/bin/env ruby

require 'octokit'
require 'date'

client = Octokit::Client.new(netrc: true, per_page:10)
client.login

repos = ['verify-hub', 'verify-matching-service-adapter', 'verify-frontend']

repos.each do |repo|
  puts "------------------ #{repo} ---------------------"

  pull_requests = client.pull_requests("alphagov/#{repo}", :state => 'all')

  pull_requests.each do |pr|
    pr_detail = client.pull_request("alphagov/#{repo}", pr.number)
    #only looks at comments not reviews - perhapse we need to define how to work with reviews
    comments = client.issue_comments("alphagov/#{repo}", pr.number)
    commits = client.pull_request_commits("alphagov/#{repo}", pr.number)

    parent_sha = commits.first.parents.first.sha
    parent_commit = client.commit("alphagov/#{repo}", parent_sha)
  #  parent_date = DateTime.parse(parent_commit.commit.author.date)

    files_changed = client.pull_request_files("alphagov/#{repo}", pr.number).length
    puts "Pull request #{pr.number} contained #{pr_detail.commits} commits, modified #{pr_detail.changed_files} files with #{pr_detail.additions} additions and with #{pr_detail.deletions} deletions, was raised by #{pr.user.login} had #{pr_detail.comments} comments"
    if pr_detail.merged
      puts "it was merged by #{pr_detail.merged_by.login}"
      puts "a branch was open for #{(pr_detail.merged_at.to_date - parent_commit.commit.author.date.to_date).to_i} days"
    end
  end

end
