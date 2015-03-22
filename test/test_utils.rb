require 'helper'

class TestUtils < JekyllUnitTest
  context "hash" do

    context "pluralized_array" do

      should "return empty array with no values" do
        data = {}
        assert_equal [], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return empty array with no matching values" do
        data = { 'foo' => 'bar' }
        assert_equal [], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return plural array with nil singular" do
        data = { 'foo' => 'bar', 'tag' => nil, 'tags' => ['dog', 'cat'] }
        assert_equal ['dog', 'cat'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return single value array with matching singular" do
        data = { 'foo' => 'bar', 'tag' => 'dog', 'tags' => ['dog', 'cat'] }
        assert_equal ['dog'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return single value array with matching singular with spaces" do
        data = { 'foo' => 'bar', 'tag' => 'dog cat', 'tags' => ['dog', 'cat'] }
        assert_equal ['dog cat'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return empty array with matching nil plural" do
        data = { 'foo' => 'bar', 'tags' => nil }
        assert_equal [], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return empty array with matching empty array" do
        data = { 'foo' => 'bar', 'tags' => [] }
        assert_equal [], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return single value array with matching plural with single string value" do
        data = { 'foo' => 'bar', 'tags' => 'dog' }
        assert_equal ['dog'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return multiple value array with matching plural with single string value with spaces" do
        data = { 'foo' => 'bar', 'tags' => 'dog cat' }
        assert_equal ['dog', 'cat'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return single value array with matching plural with single value array" do
        data = { 'foo' => 'bar', 'tags' => ['dog'] }
        assert_equal ['dog'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

      should "return multiple value array with matching plural with multiple value array" do
        data = { 'foo' => 'bar', 'tags' => ['dog', 'cat'] }
        assert_equal ['dog', 'cat'], Utils.pluralized_array_from_hash(data, 'tag', 'tags')
      end

    end

  end

  context "The \`Utils.parse_date\` method" do
    should "parse a properly formatted date" do
      assert Utils.parse_date("2014-08-02 14:43:06 PDT").is_a? Time
    end

    should "throw an error if the input contains no date data" do
      assert_raises Jekyll::Errors::FatalException do
        Utils.parse_date("Blah")
      end
    end

    should "throw an error if the input is out of range" do
      assert_raises Jekyll::Errors::FatalException do
        Utils.parse_date("9999-99-99")
      end
    end

    should "throw an error with the default message if no message is passed in" do
      date = "Blah this is invalid"
      assert_raises Jekyll::Errors::FatalException, "Invalid date '#{date}': Input could not be parsed." do
        Utils.parse_date(date)
      end
    end

    should "throw an error with the provided message if a message is passed in" do
      date = "Blah this is invalid"
      message = "Aaaah, the world has exploded!"
      assert_raises Jekyll::Errors::FatalException, "Invalid date '#{date}': #{message}" do
        Utils.parse_date(date, message)
      end
    end
  end

  context "The \`Utils.slugify\` method" do
    should "return nil if passed nil" do
      begin
        assert Utils.slugify(nil).nil?
      rescue NoMethodError
        assert false, "Threw NoMethodError"
      end
    end

    should "replace whitespace with hyphens" do
      assert_equal "working-with-drafts", Utils.slugify("Working with drafts")
    end

    should "replace consecutive whitespace with a single hyphen" do
      assert_equal "basic-usage", Utils.slugify("Basic   Usage")
    end

    should "trim leading and trailing whitespace" do
      assert_equal "working-with-drafts", Utils.slugify("  Working with drafts   ")
    end

    should "drop trailing punctuation" do
      assert_equal "so-what-is-jekyll-exactly", Utils.slugify("So what is Jekyll, exactly?")
      assert_equal "كيف-حالك", Utils.slugify("كيف حالك؟")
    end

    should "ignore hyphens" do
      assert_equal "pre-releases", Utils.slugify("Pre-releases")
    end

    should "replace underscores with hyphens" do
      assert_equal "the-jekyll-yml-file", Utils.slugify("The .jekyll.yml file")
    end

    should "combine adjacent hyphens and spaces" do
      assert_equal "customizing-git-git-hooks", Utils.slugify("Customizing Git - Git Hooks")
    end

    should "replace punctuation in any scripts by hyphens" do
      assert_equal "5時-6時-三-一四", Utils.slugify("5時〜6時 三・一四")
    end

    should "not modify the original string" do
      title = "Quick-start guide"
      Utils.slugify(title)
      assert_equal "Quick-start guide", title
    end

    should "not change behaviour if mode is default" do
      assert_equal "the-jekyll-yml-file", Utils.slugify("The .jekyll.yml file?", "default")
    end

    should "not change behaviour if mode is nil" do
      assert_equal "the-jekyll-yml-file", Utils.slugify("The .jekyll.yml file?", nil)
    end

    should "not replace period and underscore if mode is pretty" do
      assert_equal "the-.jekyll.yml-file", Utils.slugify("The .jekyll.yml file?", "pretty")
    end

    should "only replace whitespace if mode is raw" do
      assert_equal "the-.jekyll.yml-file?", Utils.slugify("The .jekyll.yml file?", "raw")
    end

    should "return the given string if mode is none" do
      assert_equal "the .jekyll.yml file?", Utils.slugify("The .jekyll.yml file?", "none")
    end
  end

  context "The \`Utils.add_permalink_suffix\` method" do
    should "handle built-in permalink styles" do
      assert_equal "/:basename/", Utils.add_permalink_suffix("/:basename", :pretty)
      assert_equal "/:basename:output_ext", Utils.add_permalink_suffix("/:basename", :date)
      assert_equal "/:basename:output_ext", Utils.add_permalink_suffix("/:basename", :ordinal)
      assert_equal "/:basename:output_ext", Utils.add_permalink_suffix("/:basename", :none)
    end

    should "handle custom permalink styles" do
      assert_equal "/:basename/", Utils.add_permalink_suffix("/:basename", "/:title/")
      assert_equal "/:basename:output_ext", Utils.add_permalink_suffix("/:basename", "/:title:output_ext")
      assert_equal "/:basename", Utils.add_permalink_suffix("/:basename", "/:title")
    end
  end
end
