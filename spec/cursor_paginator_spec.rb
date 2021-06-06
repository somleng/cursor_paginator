require "spec_helper"

RSpec.describe CursorPaginator do
  it "lists all records with default pagination options" do
    create_records("older", "newer", "newest")
    stub_const("#{CursorPaginator}::DEFAULT_LIMIT", 2)

    result = CursorPaginator.paginate(Post.all)

    records = result.to_a
    expect(result.size).to eq(2)
    expect(records[0].title).to eq("newest")
    expect(records[1].title).to eq("newer")
  end

  it "limits the number of records returned" do
    create_records("older", "newer", "newest")

    result = CursorPaginator.paginate(Post.all, page_options: { size: 2 })

    expect(result.size).to eq(2)
  end

  it "lists records starting after cursor with previous item cursor" do
    _, older, newer = create_records("oldest", "older", "newer", "newest")

    result = CursorPaginator.paginate(Post.all, page_options: { after: newer.id })

    records = result.to_a
    expect(result.size).to eq(2)
    expect(records[0].title).to eq("older")
    expect(records[1].title).to eq("oldest")
    expect(result).to have_prev_cursor_params(older.id)
    expect(result).to have_next_cursor_params(nil)
  end

  it "lists records starting after cursor with previous and next item cursors" do
    _, _, old, newer, newest = create_records("oldest", "older", "old", "newer", "newest")

    result = CursorPaginator.paginate(Post.all, page_options: { size: 2, after: newest.id })

    records = result.to_a
    expect(result.size).to eq(2)
    expect(records[0].title).to eq("newer")
    expect(records[1].title).to eq("old")
    expect(result).to have_prev_cursor_params(newer.id)
    expect(result).to have_next_cursor_params(old.id)
  end

  it "lists records ending before cursor with next item cursor" do
    _, older, newer = create_records("oldest", "older", "newer", "newest")

    result = CursorPaginator.paginate(Post.all, page_options: { before: older.id })

    records = result.to_a
    expect(result.size).to eq(2)
    expect(records[0].title).to eq("newest")
    expect(records[1].title).to eq("newer")
    expect(result).to have_prev_cursor_params(nil)
    expect(result).to have_next_cursor_params(newer.id)
  end

  it "lists records ending before cursor with previous and next item cursors" do
    oldest, older, old = create_records("oldest", "older", "old", "newer", "newest")

    result = CursorPaginator.paginate(Post.all, page_options: { size: 2, before: oldest.id })

    records = result.to_a
    expect(result.size).to eq(2)
    expect(records[0].title).to eq("old")
    expect(records[1].title).to eq("older")
    expect(result).to have_prev_cursor_params(old.id)
    expect(result).to have_next_cursor_params(older.id)
  end

  it "returns an empty array if the cursor is out of range" do
    record = create_records("record").first

    result = CursorPaginator.paginate(Post.all, page_options: { after: record.id })

    expect(result.size).to eq(0)
    expect(result).to have_prev_cursor_params(nil)
    expect(result).to have_next_cursor_params(nil)
  end

  context "when sort direction is ascending" do
    it "lists records in ascending order starting after cursor with previous and next item cursors" do
      oldest, older, old = create_records("oldest", "older", "old", "newer", "newest")

      result = CursorPaginator.paginate(
        Post.all,
        page_options: { size: 2, after: oldest.id },
        paginator_options: { sort_direction: :asc }
      )

      records = result.to_a
      expect(result.size).to eq(2)
      expect(records[0].title).to eq("older")
      expect(records[1].title).to eq("old")
      expect(result).to have_prev_cursor_params(older.id)
      expect(result).to have_next_cursor_params(old.id)
    end

    it "lists records in ascending order ending before cursor with previous and next item cursors" do
      _, _, old, newer, newest = create_records("oldest", "older", "old", "newer", "newest")

      result = CursorPaginator.paginate(
        Post.all,
        page_options: { size: 2, before: newest.id },
        paginator_options: { sort_direction: :asc }
      )

      records = result.to_a
      expect(result.size).to eq(2)
      expect(records[0].title).to eq("old")
      expect(records[1].title).to eq("newer")
      expect(result).to have_prev_cursor_params(old.id)
      expect(result).to have_next_cursor_params(newer.id)
    end
  end

  context "array pagination" do
    it "lists records in ascending order starting after cursor with previous and next item cursors" do
      records = create_records("oldest", "older", "old", "newer", "newest")
      oldest, older, old = records

      result = CursorPaginator.paginate(
        records,
        page_options: { size: 2, after: oldest.id },
        paginator_options: { sort_direction: :asc }
      )

      records = result.to_a
      expect(result.size).to eq(2)
      expect(records[0].title).to eq("older")
      expect(records[1].title).to eq("old")
      expect(result).to have_prev_cursor_params(older.id)
      expect(result).to have_next_cursor_params(old.id)
    end

    it "lists records in ascending order ending before cursor with previous and next item cursors" do
      records = create_records("oldest", "older", "old", "newer", "newest")
      _, _, old, newer, newest = records

      result = CursorPaginator.paginate(
        records,
        page_options: { size: 2, before: newest.id },
        paginator_options: { sort_direction: :asc }
      )

      records = result.to_a
      expect(result.size).to eq(2)
      expect(records[0].title).to eq("old")
      expect(records[1].title).to eq("newer")
      expect(result).to have_prev_cursor_params(old.id)
      expect(result).to have_next_cursor_params(newer.id)
    end
  end

  RSpec::Matchers.define :have_prev_cursor_params do |cursor|
    match do |result|
      result.prev_cursor_params == { before: cursor }
    end
  end

  RSpec::Matchers.define :have_next_cursor_params do |cursor|
    match do |result|
      result.next_cursor_params == { after: cursor }
    end
  end

  def create_records(*titles)
    titles.map { |title| Post.create(title: title) }
  end
end
