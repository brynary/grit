require File.dirname(__FILE__) + '/helper'

class TestEncodings < Test::Unit::TestCase
  def setup
    @internal_encoding = Encoding.default_internal
    @dir = Dir.mktmpdir("grit-test")
    `cd "#{@dir}" && git  init`
    @r = Repo.new(@dir)
  end

  def teardown
    Encoding.default_internal = @internal_encoding
    FileUtils.rmdir @dir
  end

  def test_english_commit_message_encoding
    index = @r.index
    index.add("README.md", "English text")
    sha = index.commit("English commit message")

    commit = @r.commit(sha)

    assert_equal Encoding::UTF_8, commit.message.encoding
  end

  def test_japanese_commit_message_encoding
    index = @r.index
    index.add("README.md", "ャストスケジ可能なマッチングも")
    sha = index.commit("ャストスケジ")

    Encoding.default_internal = Encoding::UTF_8
    commit = @r.commit(sha)

    assert_equal Encoding::UTF_8, commit.message.encoding
    assert_equal "ャストスケジ", commit.message
  end

  def test_english_file_encoding
    index = @r.index
    index.add("README.md", "English text")
    sha = index.commit("English commit message")

    blob = @r.commit(sha).tree / "README.md"
    file_contents = blob.data

    assert_equal Encoding::UTF_8, file_contents.encoding
  end

  def test_japanese_file_encoding
    index = @r.index
    index.add("README.md", "ャストスケジ可能なマッチングも")
    sha = index.commit("ャストスケジ")

    Encoding.default_internal = Encoding::UTF_8
    blob = @r.commit(sha).tree / "README.md"
    file_contents = blob.data

    assert_equal Encoding::UTF_8, file_contents.encoding
    assert_equal "ャストスケジ可能なマッチングも", file_contents
  end
end
