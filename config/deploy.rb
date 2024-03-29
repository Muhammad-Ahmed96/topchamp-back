# # config valid for current version and patch releases of Capistrano
# lock "~> 3.11.0"

# set :application, "top_champ"
# set :repo_url, "git@bitbucket.org:amplemind/topchamp_back.git"

# # Default branch is :master
# # ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp


# # Default deploy_to directory is /var/www/my_app_name
# # set :deploy_to, "/var/www/my_app_name"
# set :deploy_to, '/var/www/top_champ'

# # Default value for :format is :airbrussh.
# # set :format, :airbrussh

# # You can configure the Airbrussh format using :format_options.
# # These are the defaults.
# # set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# # Default value for :pty is false
# set :pty, true

# # Default value for :linked_files is []
# # append :linked_files, "config/database.yml"

# # Default value for linked_dirs is []
# # append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# # Default value for default_env is {}
# # set :default_env, { path: "/opt/ruby/bin:$PATH" }

# # Default value for local_user is ENV['USER']
# # set :local_user, -> { `git config user.name`.chomp }

# # Default value for keep_releases is 5
# # set :keep_releases, 5

# # Uncomment the following to require manually verifying the host key before first deploy.
# # set :ssh_options, verify_host_key: :secure
# set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
# #Comment on first deploy
# append :linked_files, "config/database.yml", "config/secrets.yml"


# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle","public/images",
#        "public/system", "public/uploads", '.bundle'


set :application, "topchamp"
set :repo_url, "git@bitbucket.org:shadowfoxtrot/topchamp-back.git"

# Deploy to the user's home directory
set :deploy_to, "/home/deploy/#{fetch :application}"

append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'

append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Only keep the last 5 releases to save disk space
set :keep_releases, 5
