class RemoveIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :likes, :user_id
    remove_index :likes, :post_id
  end
end
