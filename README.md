# Wharel

[![Gem Version](https://badge.fury.io/rb/wharel.svg)][gem]
[![Build Status](https://travis-ci.org/shioyama/wharel.svg?branch=master)][travis]

[gem]: https://rubygems.org/gems/wharel
[travis]: https://travis-ci.org/shioyama/wharel

Wharel helps you write concise Arel queries with ActiveRecord using Virtual
Rows inspired by
[Sequel](http://sequel.jeremyevans.net/rdoc/files/doc/virtual_rows_rdoc.html).

Although similar in spirit to gems like
[Squeel](https://github.com/activerecord-hackery/squeel) and
[BabySqueel](https://github.com/rzane/baby_squeel), which provide sophisticated
block-based interfaces for querying with Arel, Wharel is much much smaller. In
fact, the core of the gem is only [30 lines
long](https://github.com/shioyama/wharel/blob/master/lib/wharel.rb)! It uses a
single `BasicObject` as a [clean
room](https://www.sethvargo.com/the-cleanroom-pattern/) to evaluate
the query block. That's really all there is to it.

For a more detailed explanation of the implementation, see [this blog
post](https://dejimata.com/2018/5/30/arel-with-wharel).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wharel', '~> 0.4.0'
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

Wharel also supports most other query methods, e.g. `not`:

```ruby
Post.where.not { title.eq("foo") }
```

... and `order`:

```ruby
Post.order { title.lower }
```

Wharel also supports `select`, `having`, `pluck`, `group` and `or` in the same way.

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

Now we want to find all comments which match the title of the comment's post.
With standard Arel, you could do this with:

```ruby
posts = Post.arel_table
comments = Comment.arel_table
Comment.joins(:post).where(comments[:content].matches(posts[:title]))
```

Using Wharel, you can pass an argument to blocks to handle this case:

```ruby
Comment.joins(:post).where { |c| Post.where { |p| c.content.matches(p.title) } }
```

Much better!

## Contributing

Notice something wrong or a feature missing? Post an
[issue](https://github.com/shioyama/wharel/issues) or create a [pull
request](https://github.com/shioyama/wharel/pulls).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
