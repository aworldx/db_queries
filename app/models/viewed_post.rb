class ViewedPost < ApplicationRecord
  belongs_to :user
  belongs_to :pending_post
end
