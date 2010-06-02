Clearance.configure do |config|
  config.mailer_sender = CLEARANCE_DO_NOT_REPLY if defined?(CLEARANCE_DO_NOT_REPLY)
end