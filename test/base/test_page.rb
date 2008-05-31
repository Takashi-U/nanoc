require 'helper'

class Nanoc::PageTest < Test::Unit::TestCase

  def setup    ; global_setup    ; end
  def teardown ; global_teardown ; end

  class TestRouter

    def disk_path_for(page)
      '/disk' + page.path + 'index.html'
    end

    def web_path_for(page)
      '/web' + page.path
    end

  end

  class TestDataSource

    attr_reader :save_called, :move_called, :delete_called, :was_loaded

    def initialize
      @save_called    = false
      @move_called    = false
      @delete_called  = false
      @references     = 0
      @was_loaded     = false
    end

    def save_page(page)
      @save_called = true
    end

    def move_page(page, new_path)
      @move_called = true
    end

    def delete_page(page)
      @delete_called = true
    end

    def loading
      # Load if necessary
      up if @references == 0
      @references += 1

      yield
    ensure
      # Unload if necessary
      @references -= 1
      down if @references == 0
    end

    def up
      @was_loaded = true
    end

    def down
    end

  end

  class TestSite

    def config
      @config ||= { :output_dir => 'tmp' }
    end

    def data_source
      @data_source ||= TestDataSource.new
    end

    def page_defaults
      @page_defaults ||= Nanoc::PageDefaults.new(:foo => 'bar')
    end

    def router
      @router ||= TestRouter.new
    end

  end

  def test_initialize
    # Make sure attributes are cleaned
    page = Nanoc::Page.new("content", { 'foo' => 'bar' }, '/foo/')
    assert_equal({ :foo => 'bar' }, page.attributes)

    # Make sure path is fixed
    page = Nanoc::Page.new("content", { 'foo' => 'bar' }, 'foo')
    assert_equal('/foo/', page.path)
  end

  def test_to_proxy
    # Create page
    page = Nanoc::Page.new("content", { 'foo' => 'bar' }, '/foo/')
    assert_equal({ :foo => 'bar' }, page.attributes)

    # Create proxy
    page_proxy = page.to_proxy

    # Check values
    assert_equal('bar', page_proxy.foo)
  end

  def test_modified
    # TODO implement

    # needed for compilation:
    # - page (obviously)
    # - router (for getting disk path)
    # - compiler (for stack)
    # - site config (for output dir)

    # Create page

    # Assert not modified

    # Compile page

    # Assert modified

    # Compile page again

    # Assert not modified

    # Edit and compile page

    # Assert modified
  end

  def test_created
    # TODO implement
  end

  def test_outdated
    # TODO implement

    # Also check data sources that don't provide mtimes
  end

  def test_attribute_named
    in_dir [ 'tmp' ] do
      # Create temporary site
      create_site('testing')

      in_dir [ 'testing' ] do
        # Get site
        site = Nanoc::Site.new({})

        # Create page defaults (hacky...)
        page_defaults = Nanoc::PageDefaults.new({ :quux => 'stfu' })
        site.instance_eval { @page_defaults = page_defaults }

        # Create page
        page = Nanoc::Page.new("content", { 'foo' => 'bar' }, '/foo/')
        page.site = site

        # Test
        assert_equal('bar',  page.attribute_named(:foo))
        assert_equal('html', page.attribute_named(:extension))
        assert_equal('stfu', page.attribute_named(:quux))

        # Create page
        page = Nanoc::Page.new("content", { 'extension' => 'php' }, '/foo/')
        page.site = site

        # Test
        assert_equal(nil,    page.attribute_named(:foo))
        assert_equal('php',  page.attribute_named(:extension))
        assert_equal('stfu', page.attribute_named(:quux))
      end
    end
  end

  def test_content
    # TODO implement
  end

  def test_layout
    # TODO implement
  end

  def test_disk_path_for_normal_page
    # Create site
    site = TestSite.new

    # Create page
    page = Nanoc::Page.new("content", { :attr => 'ibutes' }, '/path/')
    page.site = site

    # Check
    assert_equal('tmp/disk/path/index.html',  page.disk_path)
    assert_equal('/web/path/',                page.web_path)
  end

  def test_disk_path_for_page_with_custom_path
    # Create site
    site = TestSite.new

    # Create page
    page = Nanoc::Page.new("content", { :custom_path => '/noobs/something.txt' }, '/path/')
    page.site = site

    # Check
    assert_equal('tmp/noobs/something.txt', page.disk_path)
    assert_equal('/noobs/something.txt',    page.web_path)
  end

  def test_web_path
    # TODO implement
  end

  def test_save
    # Create site
    site = TestSite.new

    # Create page
    page = Nanoc::Page.new("content", { :attr => 'ibutes' }, '/path/')
    page.site = site

    # Save
    assert(!site.data_source.save_called)
    assert(!site.data_source.was_loaded)
    page.save
    assert(site.data_source.save_called)
    assert(site.data_source.was_loaded)
  end

  def test_move_to
    # Create site
    site = TestSite.new

    # Create page
    page = Nanoc::Page.new("content", { :attr => 'ibutes' }, '/path/')
    page.site = site

    # Move
    assert(!site.data_source.move_called)
    assert(!site.data_source.was_loaded)
    page.move_to('/new_path/')
    assert(site.data_source.move_called)
    assert(site.data_source.was_loaded)
  end

  def test_delete
    # Create site
    site = TestSite.new

    # Create page
    page = Nanoc::Page.new("content", { :attr => 'ibutes' }, '/path/')
    page.site = site

    # Delete
    assert(!site.data_source.delete_called)
    assert(!site.data_source.was_loaded)
    page.delete
    assert(site.data_source.delete_called)
    assert(site.data_source.was_loaded)
  end

  def test_compile
    # TODO implement
    
    # - check modified
    # - check stack
  end

  def test_compile_without_layout
    # TODO implement
  end

  def test_do_filter
    # TODO implement
  end

  def test_do_filter_get_filters_for_stage
    # TODO implement
  end

  def test_do_filter_chained
    # TODO implement
  end

  def test_do_filter_with_outdated_filters_attribute
    # Create page
    page = Nanoc::Page.new("content", { :filters => [ 'asdf' ] }, '/path/')

    # Filter
    assert_raise Nanoc::Errors::NoLongerSupportedError do
      page.instance_eval { filter!(:pre) }
    end
  end

  def test_do_filter_with_unknown_filter
    # TODO implement
  end

  def test_do_layout
    # TODO implement
  end

  def test_do_layout_without_layout
    # TODO implement
  end

  def test_do_layout_with_unknown_filter
    # TODO implement
  end

  def test_write_page
    # TODO implement
  end

  def test_write_page_with_skip_output
    # TODO implement
  end

end
