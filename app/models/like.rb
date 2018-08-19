class Like < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :post, counter_cache: true

  def self.add_like(post_id)
    Like.transaction do
      likes = Like.where(post_: post_id).lock(true)
      
      sleep(1000000)
    end
  end
end
