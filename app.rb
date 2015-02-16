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

  case payload['action']
  when 'opened'
    issue_opened payload
  when 'unlabeled'
    issue_unlabeled payload
  end
end

def issue_opened(payload)
  repo = payload['repository']['full_name']
  number = payload['issue']['number']

  label_issue repo, number, 'new'
end

def issue_unlabeled(payload)
  repo = payload['repository']['full_name']
  number = payload['issue']['number']

  # Add new label if issue is open and has no other labels
  if payload['issue']['state'] == 'open' && payload['issue']['labels'].empty?
    label_issue repo, number, 'new'
  end
end

def label_issue(repo, number, *labels)
  github_client.add_labels_to_an_issue repo, number, labels
end

def github_client
  Octokit::Client.new access_token: ENV['GITHUB_TOKEN']
end
