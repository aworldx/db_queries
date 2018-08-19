class AddPartialIndexesToPendingPosts < ActiveRecord::Migration[5.2]
  def change
    add_index :pending_posts, :banned, where: "banned = true"
    add_index :pending_posts, :approved, where: "approved = false"
  end
end
