require 'helper'

class TestCaplock < Test::Unit::TestCase
  def setup
    @config = Capistrano::Configuration.new
    Capistrano::Caplock.load_into(@config)
    @config.set :deploy_to, "/tmp"
    @config.role :app, "localhost"
  end
  
  should "use default lockfile name 'cap.lock'" do
    assert_equal @config.lockfile, 'cap.lock'
  end
  
  should "set lockfile name to 'test.lock'" do
    @config.set :lockfile, 'test.lock'
    assert_equal @config.lockfile, 'test.lock'
  end
  
  should "create lock" do
     assert_nil @config.lock.create
     assert File.exists?("/tmp/cap.lock")
  end
  
  should "remove lock" do
     assert_nil @config.lock.create
     assert_nil @config.lock.release
     assert !File.exists?("/tmp/cap.lock")
  end
  
  should "check for lock and pass" do
     assert_nil @config.lock.release
     assert_nil @config.lock.check
  end
  
  # FIXME: need to find a way to test 'abort'
  should "check for lock and abort" do
     assert_nil @config.lock.create
     #assert_raises SystemExit, @config.lock.check
  end
  
  should "check if remote file exists" do
     @config.set :lockfile, 'test.lock'
     assert_nil @config.lock.create
     assert @config.caplock.remote_file_exists?("/tmp/test.lock")
  end
end
