class AddIndexesToLikes < ActiveRecord::Migration[5.2]
  def change
    add_index :likes, :user_id
    add_index :likes, :post_id
  end
end
