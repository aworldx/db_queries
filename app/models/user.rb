class User < ApplicationRecord
  has_many :posts
  has_many :likes
  has_many :pending_posts
  has_many :viewed_posts
end
