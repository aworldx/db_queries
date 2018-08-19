start_index = User.last.try(:id) || 1

100.times do |i|
  users = []
  1000.times do |k|
    current_index = start_index + i * 1000 + k
    user = User.new(name: Faker::Name.name_with_middle, email: Faker::Internet.email)

    rand(0..10).times do
      post = user.posts.build(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph)
      rand(0..10).times do
        post.likes.build(user_id: rand(start_index..current_index))
      end
    end

    users << user
  end
  User.import users, recursive: true
end

Post.find_in_batches(finish: 10000) do |group|
  pending_posts = []
  group.each do |post|
    rand(0..100).times do
      banned = rand(1..10) == 10 ? true : false
      approved = rand(1..10) == 10 ? false : true
      pending_posts << PendingPost.new(post_id: post.id,
                                       user_id: post.user_id,
                                       approved: approved,
                                       banned: banned)
    end
  end
  PendingPost.import pending_posts
end

index_range = (User.first.id..User.last.id)

PendingPost.find_in_batches do |group|
  viewed_posts = []
  group.each do |pending_post|
    if rand(1..10) < 5
      vp = ViewedPost.new(pending_post_id: pending_post.id,
                          user_id: rand(index_range))
      viewed_posts << vp
    end
  end
  ViewedPost.import viewed_posts
end






