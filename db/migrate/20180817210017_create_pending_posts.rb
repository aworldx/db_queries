class CreatePendingPosts < ActiveRecord::Migration[5.2]
  def change
    create_table :pending_posts do |t|
      t.bigint :user_id
      t.bigint :post_id
      t.boolean :approved
      t.boolean :banned

      t.timestamps
    end
  end
end
