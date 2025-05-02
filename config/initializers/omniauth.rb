Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], access_type: "online", prompt: ""
end

OmniAuth.config.allowed_request_methods = %i[get]
OmniAuth.config.silence_get_warning = true

# Handle OmniAuth failures
OmniAuth.config.on_failure = Proc.new do |env|
  message_key = env["omniauth.error.type"]
  error_description = env["omniauth.error"]&.error_reason || env["omniauth.error"]&.message
  new_path = "#{env['SCRIPT_NAME']}#{OmniAuth.config.path_prefix}/failure?message=#{message_key}&error_description=#{error_description}"
  [ 302, { "Location" => new_path, "Content-Type"=> "text/html" }, [] ]
end
