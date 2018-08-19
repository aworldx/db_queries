class PendingPost < ApplicationRecord
  belongs_to :user
  belongs_to :post
  has_many :viewed_posts
end
