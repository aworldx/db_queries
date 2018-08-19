class Post < ApplicationRecord
  belongs_to :user
  has_many :likes
  has_many :pending_posts
end
