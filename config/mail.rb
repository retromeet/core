# frozen_string_literal: true

if Environment.development? && !EnvironmentConfig.use_smtp?
  Mail.defaults do
    delivery_method LetterOpener::DeliveryMethod, location: File.expand_path("../tmp/letter_opener", __dir__)
  end
elsif Environment.test?
  Mail.defaults do
    delivery_method :test
  end
else
  case EnvironmentConfig.smtp_enable_starttls
  when "always"
    enable_starttls = true
  when "never"
    enable_starttls = false
  when "auto"
    enable_starttls_auto = true
  else
    enable_starttls_auto = EnvironmentConfig.smtp_enable_starttls_auto
  end

  Mail.defaults do
    delivery_method :smtp, {
      port: EnvironmentConfig.smtp_port,
      address: EnvironmentConfig.smtp_server,
      user_name: EnvironmentConfig.smtp_login,
      password: EnvironmentConfig.smtp_password,
      domain: EnvironmentConfig.smtp_domain || EnvironmentConfig.retromeet_core_host,
      authentication: EnvironmentConfig.smtp_auth_method == "none" ? nil : EnvironmentConfig.smtp_auth_method || :plain,
      ca_file: EnvironmentConfig.smtp_ca_file || "/etc/ssl/certs/ca-certificates.crt",
      openssl_verify_mode: EnvironmentConfig.smtp_openssl_verify_mode,
      enable_starttls: enable_starttls,
      enable_starttls_auto: enable_starttls_auto,
      tls: EnvironmentConfig.smtp_tls,
      ssl: EnvironmentConfig.smtp_ssl,
      read_timeout: 20
    }
  end
end
