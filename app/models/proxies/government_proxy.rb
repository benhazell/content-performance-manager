require 'json'

module Proxies
  class GovernmentProxy < Rack::Proxy
    PROXY_BASE_PATH = '/proxy/govuk/'.freeze

    def rewrite_env(env)
      env['HTTP_HOST'] = 'www.gov.uk:443'
      env['REQUEST_URI'] = env['HTTP_HOST']
      env['SERVER_NAME'] = 'www.gov.uk'
      env['SERVER_PORT'] = 443
      env['SCRIPT_NAME'] = nil
      env['HTTP_X_FORWARDED_PORT'] = nil
      env['HTTP_X_FORWARDED_PROTO'] = nil
      env['rack.ssl_verify_none'] = true
      env['rack.url_scheme'] = 'https'
      env
    end

    def rewrite_response(triplet)
      status, headers, body = triplet
      [status, headers.tap { |h| h['x-frame-options'] = 'ALLOWALL' }, body]
    end
  end
end
