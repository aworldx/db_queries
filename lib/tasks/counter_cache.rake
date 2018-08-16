desc 'Counter cache for likes'

task task_counter: :environment do
  Post.find_each { |post| Post.reset_counters(post.id, :likes) }
  User.find_each { |user| User.reset_counters(user.id, :likes) }
end
