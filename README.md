[![Build Status](https://travis-ci.com/GeorgeKaraszi/ActiveRecordExtended.svg?branch=master)](https://travis-ci.com/GeorgeKaraszi/ActiveRecordExtended) [![Maintainability](https://api.codeclimate.com/v1/badges/98ecffc0239417098cbc/maintainability)](https://codeclimate.com/github/GeorgeKaraszi/active_record_extended/maintainability)

## Index
- [Description and history](#description-and-history)
- [Installation](#installation)
- [Useage](#usage)
  - [Query Methods](#query-methods)
    - [Any](#any)
    - [All](#all)
    - [Contains](#contains)
    - [Contains or Equals](#contains-or-equals)
    - [Contained Within](#contained-within)
    - [Contained Within or Equals](#contained-within-or-equals)
    - [Overlap](#overlap)
  - [Conditional Methods](#conditional-methods)
    - [Any_of / None_of](#any_of--none_of)
    - [Either Join](#either-join)
    - [Either Order](#either-order)

## Description and History

Active Record Extended is the continuation of maintaining and improving the work done by **Dan McClain**, the original author of [postgres_ext](https://github.com/DavyJonesLocker/postgres_ext).

Overtime the lack of updating to support the latest versions of ActiveRecord 5.x has caused quite a bit of users forking off the project to create their own patches jobs to maintain compatibility. 
The only problem is that this has created a wild west of environments of sorts. The problem has grown to the point no one is attempting to directly contribute to the original source. And forked repositories are finding themselves as equally as dead with little to no activity.

Active Record Extended is intended to be a supporting community that will maintain compatibility for the foreseeable future.


## Usage

### Query Methods

#### Any
[Postgres 'ANY' expression](https://www.postgresql.org/docs/10/static/functions-comparisons.html#id-1.5.8.28.16)

In Postgres the `ANY` expression is used for gather record's that have an Array column type that contain a single matchable value within its array. 

```ruby
person_one   = Person.create!(tags: [1])
person_two   = Person.create!(tags: [1, 2])
person_three = Person.create!(tags: [3])

Person.where.any(tags: 1) #=> [person_one, person_two] 

```

This only accepts a single value. So querying for example multiple tag numbers `[1,2]` will return nothing.


#### All
[Postgres 'ALL' expression](https://www.postgresql.org/docs/10/static/functions-comparisons.html#id-1.5.8.28.17)

In Postgres the `ALL` expression is used for gather record's that have an Array column type that contains only a **single** and matchable element. 

```ruby
person_one   = Person.create!(tags: [1])
person_two   = Person.create!(tags: [1, 2])
person_three = Person.create!(tags: [3])

Person.where.all(tags: 1) #=> [person_one] 

```

This only accepts a single value to a given attribute. So querying for example multiple tag numbers `[1,2]` will return nothing.

#### Contains
[Postgres '@>' (Array type) Contains expression](https://www.postgresql.org/docs/10/static/functions-array.html)

[Postgres '@>' (JSONB/HSTORE type) Contains expression](https://www.postgresql.org/docs/10/static/functions-json.html#FUNCTIONS-JSONB-OP-TABLE)


The `contains/1` method is used for finding any elements in an `Array`, `JSONB`, or `HSTORE` column type. 
That contains all of the provided values.

Array Type:
```ruby
person_one   = Person.create!(tags: [1, 4])
person_two   = Person.create!(tags: [3, 1])
person_three = Person.create!(tags: [4, 1])

Person.where.contains(tags: [1, 4]) #=> [person_one, person_three]
```

HSTORE / JSONB Type:
```ruby
person_one   = Person.create!(data: { nickname: "ARExtend" })
person_two   = Person.create!(data: { nickname: "ARExtended" })
person_three = Person.create!(data: { nickname: "ARExtended" })

Person.where.contains(data: { nickname: "ARExtended" }) #=> [person_two, person_three]
```

#### Contains or Equals
#### Contained Within
#### Contained Within or Equals
#### Overlap
[Postgres && (overlap) Expression](https://www.postgresql.org/docs/10/static/functions-array.html)

The `overlap/1` method will match an Array column type that contains any of the provided values within its column.

```ruby
person_one   = Person.create!(tags: [1, 4])
person_two   = Person.create!(tags: [3, 4])
person_three = Person.create!(tags: [4, 8])

Person.where.overlap(tags: [4]) #=> [person_one, person_two, person_three]
Person.where.overlap(tags: [1, 8]) #=> [person_one, person_three]
Person.where.overlap(tags: [1, 3, 8]) #=> [person_one, person_two, person_three]

```


### Conditional Methods
#### Any_of / None_of
 `any_of/1` simplifies the process of finding records that require multiple `or` conditions.
 It accepts An array of: ActiveRecord Objects, Query Strings, and basic attribute names
 
 Querying With Attributes:
 ```ruby
person_one   = Person.create!(uid: 1)
person_two   = Person.create!(uid: 2)
person_three = Person.create!(uid: 3)

Person.where.any_of({ uid: 1 }, { uid: 2 }) #=> [person_one, person_two]
```

Querying With ActiveRecord Objects:
```ruby
person_one   = Person.create!(uid: 1)
person_two   = Person.create!(uid: 2)
person_three = Person.create!(uid: 3)

uid_one = Person.where(uid: 1)
uid_two = Person.where(uid: 2)

Person.where.any_of(uid_one, uid_two) #=> [person_one, person_two]
```

Querying with Joined Relationships:
```ruby
person_one       = Person.create!(uid: 1)
person_two       = Person.create!(uid: 2)
person_three     = Person.create!(uid: 3)
tag_one          = Tag.create!(person_id: person_one.id)
tag_two          = Tag.create!(person_id: person_two.id)
tag_three        = Tag.create!(person_id: person_three.id)

person_two_tag   = Tag.where(people: { id: two.id }).includes(:person)
person_three_tag = Tag.where(people: { id: three.id }).joins(:person)

Tag.joins(:person).where.any_of(person_two_tag, person_three_tag) #=> [tag_two, tag_three] (with person table joined)
```

#### Either Join
#### Either Order

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_extended'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_extended


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
