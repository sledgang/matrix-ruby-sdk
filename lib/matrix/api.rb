module Matrix
  # Api call wrapper
  class Api

    def initialize(token, base)
      @token = token
      @base = base
    end

    def authed_get(url)
      Faraday.get("#{@base}#{url}",
                  access_token: @token)
    end

    def authed_post(url, hash = {})
      hash[:access_token] = @token
      Faraday.post("#{@base}#{url}",
                  hash)
    end

    def json_post(url, hash = {})
      Faraday.post("#{@base}#{url}") do |req|
        req.headers['Content-Type'] = 'application/json'
        req.body = hash.to_json
      end
    end

    def self.json_post(url, hash = {})
      new('', '').json_post(url, hash)
    end
  end
end
