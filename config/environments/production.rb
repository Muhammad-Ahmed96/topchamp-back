Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "topchamp_#{Rails.env}"

  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.front_url = "http://pick-frontend.s3-website.us-east-2.amazonaws.com/"
  config.front_event_url = config.front_url + "/mail/events/wizard/detail/{id}/basics/?type=event&id={id}&invitatio_id={invitatio_id}"
  config.front_sing_up_url = config.front_url + "/auth/register?type=sign_up"
  config.front_date_url = config.front_url + "/mail/events/wizard/detail/{id}/basics/?type=date&id={id}&invitatio_id={invitatio_id}"
  config.front_partner_url = config.front_url + "/auth?type=need_partner&id={id}&event_id={event_id}&invitation_type={invitation_type}&by=invitation"
  config.front_partner_choose_url = config.front_url + "/auth?type=choose_partner&id={id}&event_id={event_id}&invitation_type={invitation_type}&by=invitation"
  config.front_new_spot_url = config.front_url + "?type=new_spot&event_id={event_id}&event_bracket_id={event_bracket_id}&category_id={category_id}"
  config.front_login = config.front_url + "/auth"    

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
  config.action_mailer.asset_host = 'ec2-3-135-231-220.us-east-2.compute.amazonaws.com'
  config.action_mailer.default_url_options = { host: 'ec2-3-135-231-220.us-east-2.compute.amazonaws.com' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address => "smtp.sendgrid.net",
      :port => "587",
      :domain => "ec2-3-135-231-220.us-east-2.compute.amazonaws.com",
      :user_name => "apikey",
      :password => ENV["SENDGRID_API_KEY"],
      :authentication => "plain",
      :enable_starttls_auto => true  }
end