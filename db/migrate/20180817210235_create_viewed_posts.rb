class CreateViewedPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :viewed_posts do |t|
      t.bigint :user_id
      t.bigint :pending_post_id

      t.timestamps
    end
  end
end
