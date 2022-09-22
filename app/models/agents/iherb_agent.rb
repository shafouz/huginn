module Agents
  class IherbAgent < Agent
    default_schedule 'every_1h'

    description <<-MD
      Get payload from github event and process it.
    MD

    def default_options
    end

    def check_commits(data)
      user, repo = data[:repo].split("/")
      commits = data[:commits]

      commits.each do |commit|
        temp = github.repos.commits.get user, repo, commit[:sha]
        if temp.files.to_s =~ /iherb/i || temp.commit.message =~ /iherb/i
          create_event payload: {
            repo: data[:repo],
            created_at: data[:created_at],
            url: "https://github.com/#{data[:repo]}/commit/#{commit[:sha]}"
          }
        end
      end
    end

    def receive(events)
      events.each do |event|
        commits = event.payload["last"]["payload"]["commits"]
        repo = event.payload["last"]["repo"]["name"]
        created_at = DateTime.parse(event.payload["last"]["created_at"]).inspect

        check_commits({ repo: repo, commits: commits, created_at: created_at })
      end
    end

    def validate_options
      true
    end

    def working?
      true
    end

    def check
    end

    private
    def github
      gh = Github.new oauth_token: ENV['GITHUB_ACCESS_KEY']
    end
  end
end
