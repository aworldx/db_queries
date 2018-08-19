class AddIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :viewed_posts, :user_id
  end
end
