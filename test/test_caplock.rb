require 'helper'

class StubLogger
  def close ; end
  def log(level, message, line_prefix=nil) ; end
  def important(message, line_prefix=nil) ; end
  def info(message, line_prefix=nil) ; end
  def debug(message, line_prefix=nil) ; end
  def trace(message, line_prefix=nil); end
  def format(message, color, style, nl = "\n") ; end
end

class TestCaplock < Test::Unit::TestCase
  class TestCaplockError < RuntimeError ; end

  def setup
    @update_code_raise = false;
    @config = Capistrano::Configuration.new
    @config.load do
      namespace :deploy do
        task :default do
          transaction do
            update_code
          end
        end
        task :update_code do
          raise TestCaplockError, "update_code simulated exception" if caplock_update_code_raise
        end
      end
    end
    @config.logger = StubLogger.new
    #@config.logger = Capistrano::Logger.new :level => Capistrano::Logger::MAX_LEVEL
    Capistrano::Caplock.load_into(@config)
    @config.set :deploy_to, "/tmp"
    @config.set :caplock_update_code_raise, false
    @config.role :app, "localhost"

    # ensure clean test
    File.unlink("/tmp/cap.lock") if File.exists?("/tmp/cap.lock")
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
  
  should "check for lock and abort" do
     assert_nil @config.lock.create
     assert_raises(Capistrano::Caplock::LockedDeployError) { @config.lock.check }
  end
  
  should "check if remote file exists" do
     @config.set :lockfile, 'test.lock'
     assert_nil @config.lock.create
     assert @config.caplock.remote_file_exists?("/tmp/test.lock")
  end

  should "remove lock on rollback" do
    @config.set :caplock_update_code_raise, true
    assert_raises(TestCaplockError) { @config.deploy.default }
    assert_nil @config.lock.check
  end

  should "not remove lock owned by other process" do
    File.open("/tmp/cap.lock", "w") { |file| file.write("Simulate cap.lock from another deploy process") }
    assert File.exists?("/tmp/cap.lock")
    assert_raises(Capistrano::Caplock::LockedDeployError) { @config.deploy.default }
    # rollback should not have removed the file, so it is still locked
    assert_raises(Capistrano::Caplock::LockedDeployError) { @config.lock.check }
  end

  should "remove lock owned by other process on manual release" do
    File.open("/tmp/cap.lock", "w") { |file| file.write("Simulate cap.lock from another deploy process") }
    assert File.exists?("/tmp/cap.lock")
    assert_nil @config.lock.release
    assert_nil @config.lock.check
  end
end
