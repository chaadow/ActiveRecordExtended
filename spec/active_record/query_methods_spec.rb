# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Active Record Querying" do
  let!(:one)   { Person.create!(tags: [1, 2, 3],  personal_id: 33, data: { nickname: "george" }) }
  let!(:two)   { Person.create!(tags: [3, 1, 5],  personal_id: 88, data: { nickname: "dan"    }) }
  let!(:three) { Person.create!(tags: [2, 8, 20], personal_id: 33, data: { nickname: "georgey" }) }

  describe "#overlap" do
    it "Should return matched records" do
      query = Person.where.overlap(tags: [1])
      expect(query).to include(one, two)
      expect(query).to_not include(three)

      query = Person.where.overlap(tags: [2, 3])
      expect(query).to include(one, two, three)
    end
  end

  describe "#contains" do
    it "returns records that contain elements in an array" do
      query = Person.where.contains(tags: [1, 3])
      expect(query).to include(one, two)
      expect(query).to_not include(three)

      query = Person.where.overlap(tags: [8, 2])
      expect(query).to include(one, three)
      expect(query).to_not include(two)
    end

    it "returns records that contain hash elements in joined tables" do
      tag = Tag.create!(person_id: one.id)

      query = Tag.joins(:person).where.contains(people: { data: { nickname: "george" } })
      expect(query).to include(tag)
    end

    it "returns records that contain hash value" do
      query = Person.where.contains(data: { nickname: "george" })
      expect(query).to include(one)
      expect(query).to_not include(two, three)
    end
  end

  describe "#any" do
    it "should return any records that match" do
      query = Person.where.any(tags: 3)
      expect(query).to include(one, two)
      expect(query).to_not include(three)
    end

    it "allows chaining" do
      query = Person.where.any(tags: 3).where(personal_id: 33)
      expect(query).to include(one)
      expect(query).to_not include(two, three)
    end
  end

  describe "#all" do
    let!(:contains_all)     { Person.create!(tags: [1], personal_id: 1) }
    let!(:contains_all_two) { Person.create!(tags: [1], personal_id: 2) }
    let!(:contains_some)    { Person.create!(tags: [1, 2], personal_id: 2) }

    it "should return any records that match" do
      query = Person.where.all(tags: 1)
      expect(query).to include(contains_all, contains_all_two)
      expect(query).to_not include(contains_some)
    end

    it "allows chaining" do
      query = Person.where.all(tags: 1).where(personal_id: 1)
      expect(query).to include(contains_all)
      expect(query).to_not include(contains_all_two, contains_some)
    end
  end
end