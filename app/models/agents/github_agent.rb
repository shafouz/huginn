module Agents
  class GithubAgent < Agent
    cannot_receive_events!

    default_schedule 'every_1h'

    description <<-MD
    Watch for updates hourly on github.
      Need to check if its a PushEvent.
      MD

    def default_options
      {
        'users' => %w[user1 user2]
      }
    end

    def validate_options
      errors.add(:base, 'User is required') unless !!!options['users'].blank?
    end

    def working?
      # Implement me! Maybe one of these next two lines would be a good fit?
      # checked_without_error?
      # received_event_without_error?
      true
    end

    def check
      users = options['users']

      users.each do |user|
        performed = github.activity.events.performed(user)
        next if performed.blank?

        performed.each do |event|
          begin
            GithubEventId.create(unique_id: event.id)
          rescue
            next
          end

          url = event.repo.url.gsub("https://api.","https://").gsub("/repos/","/")
          if event.created_at > DateTime.now.advance(days: -15).getutc && event.type == "PushEvent"
            create_event payload: {"repo_url":url,"last":event}
          end
        end
      end
    end

    private
    def github
      gh = Github.new oauth_token: ENV['GITHUB_ACCESS_KEY']
    end
  end
end
