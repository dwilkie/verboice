class OAuth2::Client
  oauth_path = "#{Rails.root}/config/oauth.yml"
  @@oauth_data = File.exists?(oauth_path) ? YAML::load(File.open(oauth_path)) : {}

  def self.google
    api_key, api_secret = self.client_data_for(:google)
    OAuth2::Client.new(api_key, api_secret, :site => 'https://accounts.google.com/', :authorize_url => '/o/oauth2/auth', :token_url => 'o/oauth2/token')
  end

  def self.service_configured?(service)
    @@oauth_data.include?(service.to_s) && !@@oauth_data[service.to_s]['api_key'].blank? && !@@oauth_data[service.to_s]['api_secret'].blank?
  end

  protected

  def self.client_data_for(service)
    raise "OAuth2: Service not supported '#{service}'.\nAvailable services are: #{@@oauth_data.keys.join(', ')}" if not service_configured?(service)
    client_data = @@oauth_data[service.to_s]
    return [client_data['api_key'], client_data['api_secret']]
  end
end