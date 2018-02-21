#!/usr/bin/env ruby

require 'octokit'

client = Octokit::Client.new(netrc: true, per_page:100)
client.login

repos = ['verify-matching-service-adapter',
  'ida-hub-support',
  'verify-hub',
  'verify-eidas-notification',
  'verify-frontend',
  'verify-service-provider'
]

repos.each do |repo|
  puts "------------------ #{repo} ---------------------"

  commits = client.commits("alphagov/#{repo}")

  pairing_count = 0
  solo_count = 0
  soloers =[]
  commits.each do |commit|
    next if commit.commit.message.start_with?('Merge')
      authors = commit.commit.message.scan(/(?<!\w)@\w+/)
      if authors.length > 1
        pairing_count += 1
      else
        soloers.push(commit.commit.author.name)
        solo_count += 1
      end
    end

    total_commits = pairing_count + solo_count
    pairing_percentage = pairing_count.to_f/total_commits*100
    solo_percentage = solo_count.to_f/total_commits*100
    puts "#{repo}: #{pairing_count} commits out of the last #{total_commits} have been paired on (#{pairing_percentage.round}%)"
    puts "#{repo}: #{solo_count} commits out of the last  #{total_commits} have not been paired on (#{solo_percentage.round}%)"

    solo_count = soloers.inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}
    solo_count.sort_by(&:last).each do |name, count|
      puts "#{name} soloed on #{count} commits"
    end

end
