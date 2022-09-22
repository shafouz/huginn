class CreateGithubEventIds < ActiveRecord::Migration[6.0]
  def change
    create_table :github_event_ids do |t|
      t.text :unique_id, index: { unique: true }

      t.timestamps
    end
  end
end
