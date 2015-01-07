require 'json'

require 'sinatra'
require 'octokit'

get '/' do
  'issues'
end

post '*' do
  handle_payload
  200
end

def handle_payload
  payload = JSON.parse request.body.read
  if payload['action'] == 'opened'
    issue_opened payload['repository']['full_name'], payload['issue']['number']
  end
end

def issue_opened(repo, number)
  label_issue repo, number, 'new'
end

def label_issue(repo, number, *labels)
  github_client.add_labels_to_an_issue repo, number, labels
end

def github_client
  Octokit::Client.new access_token: ENV['GITHUB_TOKEN']
end
