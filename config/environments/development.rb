Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.asset_host = 'http://topchamp.com'
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      tls: true,
      address:              'secure.emailsrvr.com',
      port:                 465,
      user_name:            'testomator@amplemind.com',
      password:             'Password01',
      authentication:       :login  }
  config.hours_bracket = 8
  config.front_url = "http://topchampdev.tk:444"
  config.front_event_url = config.front_url + "/mail/events/wizard/detail/{id}/basics/?type=event&id={id}&invitatio_id={invitatio_id}"
  config.front_sing_up_url = config.front_url + "/auth/register?type=sign_up"
  config.front_date_url = config.front_url + "/mail/events/wizard/detail/{id}/basics/?type=date&id={id}&invitatio_id={invitatio_id}"
  config.front_partner_url = config.front_url + "?type=need_partner&id={id}&event_id={event_id}&invitation_type={invitation_type}"
  config.front_partner_choose_url = config.front_url + "?type=choose_partner&id={id}&event_id={event_id}&invitation_type={invitation_type}"
  config.front_new_spot_url = config.front_url + "?type=new_spot&event_id={event_id}&event_bracket_id={event_bracket_id}&category_id={category_id}"
  config.front_login = config.front_url + "/auth"


  config.fcm_api_key = 'AAAAnBYb9iI:APA91bEsGI3blVOPYbi7iaIDyBXi3J9H7N-bHzVfPOaPJDWIOYs7sS42jQxj_KJy_5Rjh9HO7BTMN33Om7f4Y_Ndcouq_0QvaKuFB6APXZyE-M6_OTW5W4GShjWpDKP0OniVlLTEiHgbl8_37djkRUxwkJxfnUvf5A'

  config.authorize = {
      api_login_id: '5KP3u95bQpv',
      api_transaction_key: '346HZ32z3fP4hTG2',
      gateway: :sandbox,
      transaction_fee: 2.9,
      extra_charges: 0.3,
  }
end
