Capistrano::Configuration.instance.load do
  
  set :lockfile, "cap.lock"
  
  # Returns Boolean indicating the result of +filetest+ on +full_path+ on the server, evaluated by shell on 
  # the server (usually bash or something roughly compatible).
  def remote_filetest_passes?(filetest, full_path)
    'true' ==  capture("if [ #{filetest} #{full_path} ]; then echo 'true'; fi").strip
  end
  
  # Checks if a symlink exists on the remote machine.
  def remote_symlink_exists?(full_path)
    remote_filetest_passes?('-L', full_path)
  end
  
  # Returns Boolean value indicating whether file exists on server
  def remote_file_exists?(full_path)
    remote_filetest_passes?('-e', full_path)
  end

  # Returns Boolean value indicating whether the file at +full_path+ matches +content+.  Checks if file
  # is equivalent to content by checking whether or not the MD5 of the remote content is the same as the
  # MD5 of the String in +content+.
  def remote_file_content_same_as?(full_path, content)
    Digest::MD5.hexdigest(content) == capture("md5sum #{full_path} | awk '{ print $1 }'").strip
  end

  # Returns Boolean indicating whether the remote file is present and has the same contents as
  # the String in +content+.
  def remote_file_differs?(full_path, content)
    !remote_file_exists?(full_path) || remote_file_exists?(full_path) && !remote_file_content_same_as?(full_path, content)
  end
  
  namespace :lock do
    desc "check lock"
    task :check, :roles => :app do
      if remote_file_exists?("#{deploy_to}/#{lockfile}")
        abort "\n\n\n\e[0;31m A Deployment is already in progress\n Remove #{deploy_to}/#{lockfile} to unlock  \e[0m\n\n\n"
      end
    end
    
    desc "create lock"
    task :create, :roles => :app do
      timestamp = Time.now.strftime("%m/%d/%Y %H:%M:%S %Z")
      lock_message = "Deploy started at #{timestamp} in progress"
      put lock_message, "#{deploy_to}/#{lockfile}", :mode => 0644
    end
    
    desc "release lock"
    task :release, :roles => :app do
       run "rm -f #{deploy_to}/#{lockfile}"
    end
  end
  
  before "deploy", "lock:check"
  after "lock:check", "lock:create"
  after "deploy", "lock:release"

end