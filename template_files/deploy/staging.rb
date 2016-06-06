_servers = (ENV['APP_IPS']).split(',').map(&:strip)

_servers.each do |s|
  server s , user: 'deploy', roles: %w{app web}
end

set :branch, ENV['BRANCH'] || :develop

set :nginx_server_name, ENV['SERVER_NAMES']

set :linked_files, %w{config/database.yml config/application.yml}

set :stage, :staging
set :rails_env, :staging
set :puma_env, :staging

set :rollbar_token, ''
