Capistrano::Configuration.instance.load do
  _cset(:bluepill_local_config) { File.join(templates_path, "app.bluepill.erb") }  
  _cset(:bluepill_remote_config) { File.join(shared_path, "config/pills/#{application}.pill") } 

  namespace :bluepill do
    desc "|capistrano-recipes| Parses and uploads bluepill configuration for this app."
    task :setup, :roles => :app, :except => { :no_release => true } do
      sudo "mkdir -p /var/run/bluepill"
      sudo "chown #{user}:#{group} /var/run/bluepill"
      generate_config(bluepill_local_config, bluepill_remote_config)
    end

    desc "|capistrano-recipes| Parses and uploads a bluepill template."
    task :template, :roles => :app , :except => { :no_release => true } do
      generate_config("#{templates_path}/template.bluepill.erb", "#{shared_path}/config/pills/template.pill")
    end

    desc "|capistrano-recipes| Install the bluepill monitoring tool"
    task :install, :roles => :app do
      run "gem install bluepill"
    end

    desc "|capistrano-recipes| Stop processes that bluepill is monitoring and quit bluepill"
    task :quit, :roles => :app do
      args = exists?(:options) ? options : ''
      begin
        run "bluepill stop #{args} --no-privileged"
      rescue
        puts "Bluepill was unable to finish gracefully all the process"
      ensure
        run "bluepill quit --no-privileged"
      end
    end

    desc "|capistrano-recipes| Load the pill from {your-app}/config/pills/{app-name}.pill"
    task :init, :roles => :app do
      run "bluepill load #{shared_path}/config/pills/#{application}.pill --no-privileged"
    end

    desc "|capistrano-recipes| Starts your previous stopped pill"
    task :start, :roles => :app do
      args = exists?(:options) ? options : ''
      app = exists?(:app) ? app : application
      run "bluepill #{app} start #{args} --no-privileged"
    end

    desc "|capistrano-recipes| Stops some bluepill monitored process"
    task :stop, :roles => :app do
      args = exists?(:options) ? options : ''
      app = exists?(:app) ? app : application
      run "bluepill #{app} stop #{args} --no-privileged"
    end

    desc "|capistrano-recipes| Restarts the pill from {your-app}/config/pills/{app-name}.pill"
    task :restart, :roles => :app do
      args = exists?(:options) ? options : ''
      app = exists?(:app) ? app : application
      run "bluepill #{app} restart #{args} --no-privileged"
    end

    desc "|capistrano-recipes| Prints bluepills monitored processes statuses"
    task :status, :roles => :app do
      args = exists?(:options) ? options : ''
      app = exists?(:app) ? app : application
      run "bluepill #{app} status #{args} --no-privileged"
    end
  end

end