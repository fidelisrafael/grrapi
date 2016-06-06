require_relative '../rake_heroku_deployer'

namespace :db do

	desc "Truncate all existing data"
	task :truncate => :environment do
		options = {}
		tables  = ENV['TABLES'].present? ? ENV['TABLES'].split(",").map(&:squish) : nil
		options[:only] = tables if tables

		DatabaseCleaner.clean_with :truncation, options
	end

end

namespace :deploy do

	DEPLOY_ENVIRONMENTS = [:staging, :production]

	DEPLOY_ENVIRONMENTS.each do |environment|
		namespace environment do
			task :migrations do
				deployer = RakeHerokuDeployer.new(environment)
				deployer.run_migrations
			end

			task :rollback do
				deployer = RakeHerokuDeployer.new(environment)
				deployer.rollback
			end
		end

		task environment do
			deployer = RakeHerokuDeployer.new(environment)
			deployer.deploy
		end
	end

	task :all do
		DEPLOY_ENVIRONMENTS.each {|env| Rake::Task["deploy:#{env}"].invoke }
	end
end

namespace :api do
  def puts_api_endpoint(endpoint)
    method = endpoint.route_method.ljust(10)
    path = endpoint.route_path.gsub(":version", endpoint.route_version)

    if ENV['DESCRIPTION'].present?
      description = endpoint.route_description
      if description
        puts ">> #{description}"
      else
        puts ">> [No Description for this endpoint]"
      end
    end

    puts "     #{method} #{path}"
  end

  desc "API Routes"
  task :routes => :environment do
    routes = API::Base.routes

    if ENV['GROUPED']
      routes.group_by { |endpoint| endpoint.route_method }.each do |method, endpoints|
        endpoints.each do |endpoint|
          puts_api_endpoint(endpoint)
        end
      end
    else
      routes.each do |endpoint|
        puts_api_endpoint(endpoint)
      end
    end

  end
end

namespace :project do
  task :statsetup do

    require 'rails/code_statistics'

    ::STATS_DIRECTORIES << ["Serializers", "app/serializers"]
    ::STATS_DIRECTORIES << ["Services",    "app/services"]
    ::STATS_DIRECTORIES << ["Uploaders",   "app/uploaders"]
    ::STATS_DIRECTORIES << ["Validators",  "app/validators"]
    ::STATS_DIRECTORIES << ["Workers",     "app/workers"]
    ::STATS_DIRECTORIES << ["Grape API",   "app/api"]
    ::STATS_DIRECTORIES << ["Lib",         "lib/"]

    # For test folders not defined in CodeStatistics::TEST_TYPES (ie: spec/)
    ::STATS_DIRECTORIES << ["Specs", "spec/"]

    CodeStatistics::TEST_TYPES << "Services specs"
  end
end

task :stats => "project:statsetup"
