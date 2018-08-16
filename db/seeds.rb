start_index = User.last.try(:id) || 1
byebug

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
