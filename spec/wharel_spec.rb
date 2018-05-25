RSpec.describe Wharel do
  before(:all) do
    m = ActiveRecord::Migration.new
    m.create_table :posts do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
    m.create_table :comments do |t|
      t.text :content
      t.integer :post_id

      t.timestamps
    end
  end
  after(:all) do
    m = ActiveRecord::Migration.new
    m.drop_table :posts
    m.drop_table :comments
  end
  before do
    class Post < ActiveRecord::Base
      has_many :comments
    end

    class Comment < ActiveRecord::Base
      belongs_to :post
    end
  end

  describe "Relation#where" do
    it "works with block format" do
      Post.create # shouldn't match this one!
      post = Post.create(title: "Arel in your Wharel!", content: "Arel in your Wharel in your Queries, oh my!")
      query = Post.where { title.eq("Arel in your Wharel!").and(content.eq("Arel in your Wharel in your Queries, oh my!")) }
      expect(query).to eq([post])
    end

    it "works with nested block format" do
      Post.create # shouldn't match this one!
      post = Post.create(title: "Arel in your Wharel!", content: "Arel in your Wharel in your Queries, oh my!")
      comment = post.comments.create(content: "arel in your wharel!")

      query = Comment.joins(:post).where { |c| Post.where { |p| c.content.matches(p.title) } }
      expect(query).to eq([comment])
    end
  end

  describe "WhereChain#not" do
    it "works with block format" do
      post = Post.create(title: "This Wharel!")
      Post.create(title: "Not this Wharel!")
      query = Post.where.not { title.eq("Not this Wharel!") }
      expect(query).to eq([post])
    end

    it "works in combination with where" do
      post1 = Post.create(title: "Wharel 1", content: "This one!")
      post2 = Post.create(title: "Wharel 2", content: "Not this one!")
      query = Post.where { title.eq("Wharel 1") }.where.not { content.eq("Not this one!") }
      expect(query).to eq([post1])
    end
  end
end
