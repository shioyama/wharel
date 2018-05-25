# Wharel

Wharel helps you write concise Arel queries with ActiveRecord using Virtual
Rows inspired by
[Sequel](http://sequel.jeremyevans.net/rdoc/files/doc/virtual_rows_rdoc.html).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wharel'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wharel

## Usage

Suppose we have a model `Post`:

```ruby
class Post < ApplicationRecord
  has_many :comments
end
```

And let's assume our `Post` has columns `title` and `content`.

Now, if we wanted to find all the posts with a title which matched the string
"foo" and content which matched the string "bar", we'd have to resort to
something like this:

```ruby
title = Post.arel_table[:title]
content = Post.arel_table[:content]
Post.where(title.matches("foo").and(content.matches("bar")))
```

With Wharel, you can drop the boilerplate and just use a block:

```ruby
Post.where { title.matches("foo").and(content.matches("bar")) }
```

Wharel will map `title` and `content` in the block to the appropriate Arel
attribute for the column.

Now suppose we have another model `Comment` with a column `content`, and a
`Post` `has_many :comments`:

```ruby
class Post < ApplicationRecord
  has_many :comments
end

class Comment < ApplicationRecord
  belongs_to :post
end
```

Now we want to find all comments which reference the title of a post. With
standard Arel, you could do this with:

```ruby
posts = Post.arel_table
comments = Comment.arel_table
Comment.where(comments[:content].matches(posts[:title]))
```

Using Wharel, you can pass an argument to blocks to handle this case:

```ruby
Comment.where { |c| Post.where { |p| c.content.matches(p.title) } }
```

Much better!

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shioyama/wharel. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wharel project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shioyama/wharel/blob/master/CODE_OF_CONDUCT.md).
