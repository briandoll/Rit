HoptoadNotifier.configure do |config|
  config.api_key = HOPTOAD_NOTIFIER_API_KEY if defined?(HOPTOAD_NOTIFIER_API_KEY)
end
