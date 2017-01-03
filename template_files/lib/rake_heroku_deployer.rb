require 'colorize'

class RakeHerokuDeployer

  DEFAULT_CONFIG_FILE_PATH = File.join('config', 'heroku-deploy.yml')

  def initialize(app_env)
    @app_env        = app_env.to_s.downcase.to_sym
    @force          = ENV['FORCE'].present?
    @run_migrations = ENV['RUN_MIGRATIONS'].present?
    @app            = ENV['APP'] || config['app_name']
  end

  def run_migrations
    turn_app_off
    migrate
    turn_app_on
  end

  def deploy
    simple_deploy
    run_migrations if @run_migrations
  end

  def rollback
    turn_app_off
    push_previous
    restart
    turn_app_on
  end

  def config
    @config ||= YAML.load(ERB.new(File.read(config_file_path)).result).fetch(@app_env.to_s, {})
  end

  def config_file_path
    ENV['HEROKU_DEPLOY_CONFIG_FILE_PATH'] || default_config_file_path
  end

  def default_config_file_path
    Rails.root.join(DEFAULT_CONFIG_FILE_PATH)
  end

  private

  def simple_deploy
    push
    set_environment_variables
    restart
    tag
  end

  def set_environment_variables
    if defined?(Figaro)
      puts "Setting environment variables based on config/application.yml for #{@app_env}".colorize(background: :white, color: :blue)
      puts "figaro heroku:set -e #{@app_env} --app #{@app} --remote=#{remote_name}"
      puts `figaro heroku:set -e #{@app_env} --app #{@app} --remote=#{remote_name}`
    end
  end

  def push
    branch_to_branch = (current_branch.length > 0) ? "#{current_branch}:master" : ""

    puts "Deploying site to Heroku in #{@app_env.to_s.upcase} environment...\n".colorize(background: :red, color: :white)

    puts "git push#{force_option} #{remote_name} #{branch_to_branch}".colorize(color: :blue, background: :white)

    puts `git push#{force_option} #{remote_name} #{branch_to_branch}`
  end

  def remote_name
    config['remote_name'] || "git@heroku.com:#{@app}.git"
  end

  def force_option
    ' -f' if @force.present? && @force == true
  end

  def current_branch
    fallback_branch = `git rev-parse --abbrev-ref HEAD`.chomp
    ENV['BRANCH'] || config['branch_name'] || fallback_branch
  end

  def release_name
    release_suffix = ENV['RELEASE_NAME'] || Time.now.utc.strftime("%Y%m%d%H%M%S")
    release_name   = "#{@app}_release-#{release_suffix}"
  end

  def restart
    if ENV['RESTART'].present?
      puts 'Restarting app servers ...'.colorize(color: :green, background: :white)
      Bundler.with_clean_env { puts `heroku restart --app #{@app}` }
    end
  end

  def tag
    puts "Tagging release as '#{release_name}'".colorize(background: :white, color: :green)
    puts `git tag -a #{release_name} -m 'Tagged release'`
    puts `git push --tags #{remote_name}`
  end

  def migrate
    puts 'Running database migrations ...'.colorize(color: :white, background: :red)
    Bundler.with_clean_env { puts `heroku run 'bundle exec rake db:migrate' --app #{@app}` }
  end

  def turn_app_on
    maintenance_status('off')
  end

  def turn_app_off
    maintenance_status('on')
  end

  def maintenance_status(status='off')
    puts "#{status == 'on' ? 'Putting' : 'Taking'} the app out of maintenance mode ..."
    puts "heroku maintenance:#{status} --app #{@app}"
    Bundler.with_clean_env { puts `heroku maintenance:#{status} --app #{@app}` }
  end

  def push_previous
    prefix = "#{@app}_release-"
    releases = `git tag`.split("\n").select { |t| t[0..prefix.length-1] == prefix }.sort
    current_release = releases.last
    previous_release = releases[-2] if releases.length >= 2
    if previous_release
      puts "Rolling back to '#{previous_release}' ..."

      puts "Checking out '#{previous_release}' in a new branch on local git repo ..."
      puts `git checkout #{previous_release}`
      puts `git checkout -b #{previous_release}`

      puts "Removing tagged version '#{previous_release}' (now transformed in branch) ..."
      puts `git tag -d #{previous_release}`
      puts `git push #{remote_name} :refs/tags/#{previous_release}`

      puts "Pushing '#{previous_release}' to Heroku master ..."
      puts `git push #{remote_name} +#{previous_release}:master --force`

      puts "Deleting rollbacked release '#{current_release}' ..."
      puts `git tag -d #{current_release}`
      puts `git push #{remote_name} :refs/tags/#{current_release}`

      puts "Retagging release '#{previous_release}' in case to repeat this process (other rollbacks)..."
      puts `git tag -a #{previous_release} -m 'Tagged release'`
      puts `git push --tags #{remote_name}`

      puts "Turning local repo checked out on master ..."
      puts `git checkout master`
      puts 'All done!'
    else
      puts "No release tags found - can't roll back!"
      puts releases
    end
  end
end
