begin
  config_file = File.join(Rails.root, 'config', 'config-local.yml')
  config = YAML.load_file(config_file)[Rails.env].symbolize_keys

  HOPTOAD_NOTIFIER_API_KEY = config[:hoptoad_notifier_api_key] if config[:hoptoad_notifier_api_key]
  CLEARANCE_DO_NOT_REPLY = config[:clearance_do_not_reply] if config[:clearance_do_not_reply]

rescue
 raise RuntimeError, "Your config-local.yml file is missing!"
end