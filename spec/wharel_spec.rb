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

  describe "Relation#select" do
    let!(:post1) { Post.create(title: "foo", content: "baz") }
    let!(:post2) { Post.create(title: "Bar", content: "baz") }

    it "works with block format" do
      expect(Post.select { title.lower.as("title") }.map(&:title)).to match_array(%w[foo bar])
    end

    it "works without block format" do
      expect(Post.select(:title).map(&:title)).to match_array(%w[foo Bar])
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

  describe "Relation#order" do
    let!(:post1) { Post.create(title: "Z") }
    let!(:post2) { Post.create(title: "a") }

    it "works with block format" do
      expect(Post.order { title }).to eq([post1, post2])
      expect(Post.order { title.lower }).to eq([post2, post1])
    end

    it "works without block format" do
      expect(Post.order(:title)).to eq([post1, post2])
      expect(Post.order("LOWER(title)")).to eq([post2, post1])
    end
  end

  describe 'grouping query methods' do
    let!(:post1) { Post.create(title: 'foo', content: 'baz') }
    let!(:post2) { Post.create(title: 'bar', content: 'baz') }
    let!(:post3) { Post.create(title: 'Foo', content: 'baz') }

    describe 'Relation#group' do
      it 'works with block format' do
        expect(Post.group { title.lower }.map { |p| p.title.downcase }).to match_array(%w[foo bar])
      end

      it 'works without block format' do
        expect(Post.group(:title).map(&:title)).to match_array(%w[foo Foo bar])
      end
    end

    describe 'Relation#having' do
      it 'works with block format' do
        expect(
          Post.group(:title).having { title.lower.eq('foo') }.map(&:title)
        ).to match_array(%w[foo Foo])
      end

      it 'works without block format' do
        expect(
          Post.group(:title).having("LOWER(title) = ?", 'foo').map(&:title)
        ).to match_array(%w[foo Foo])
      end
    end
  end

  describe 'Relation#pluck' do
    let!(:post1) { Post.create(title: 'foo') }
    let!(:post2) { Post.create(title: 'bar') }
    let!(:post3) { Post.create(title: 'Foo') }

    it 'works with block format' do
      expect(Post.pluck { title.lower }).to match_array(%w[foo bar foo])
    end

    it 'works without block format' do
      expect(Post.pluck("LOWER(title)")).to match_array(%w[foo bar foo])
    end
  end

  describe 'Relation#or' do
    let!(:post1) { Post.create(title: 'This Wharel!') }
    let!(:post2) { Post.create(title: 'Not this Wharel!') }

    it 'works with block format' do
      expect(
        Post.where { title.eq('This Wharel!') }.or { title.eq('Not this Wharel!') }
      ).to match_array([post1, post2])
    end

    it 'works without block format' do
      expect(
        Post.where(title: 'This Wharel!').or(Post.where(title: 'Not this Wharel!'))
      ).to match_array([post1, post2])
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
