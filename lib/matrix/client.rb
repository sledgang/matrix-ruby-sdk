require 'faraday'
require 'json'

module Matrix
  # A matrix client
  class Client
    def self.versions(base = 'https://matrix.org')
      response = Faraday.get("#{base}/_matrix/client/versions")
      JSON.parse response.body
    end

    def initialize(base, username, password)
      @username = username
      @password = password
      @base = base
      @on_event_handlers = []
    end

    def login
      response = Api.json_post("#{@base}/_matrix/client/r0/login",
                           type: 'm.login.password',
                           user: @username,
                           password: @password)

      raise JSON.parse(response.body) unless response.status == 200
      obj = JSON.parse response.body
      @token = obj['access_token']
      @home_server = obj['home_server']
      @user_id = obj['user_id']
      @refresh_token = obj['refresh_token']
      @api = Api.new(@token, @base)
      dispatch('logged_in', token: token)
    end

    def tokenrefresh
      return if @refresh_token.nil?
      response = @api.json_post('/_matrix/client/r0/tokenrefresh',
                                refresh_token: @refresh_token)
      obj = JSON.parse response.body
      raise obj unless response.status == 200

      @token = obj['access_token']
      @refresh_token = obj['refresh_token']
    end

    # Possible error?
    def logout
      raise 'not logged in' unless logged_in?
      response = @api.authed_post('/_matrix/client/r0/logout')
      raise JSON.parse(obj) unless response.status == 200
      @token = nil
      dispatch('logged_out', {})
    end

    def logged_in?
      !@token.nil?
    end

    attr_accessor :base
    attr_accessor :username
    attr_accessor :password
    attr_reader :token
    attr_reader :home_server
    attr_reader :user_id

    def on_event(event, &block)
      @on_event_handlers << Handler.new(event, &block)
    end

    private

    def dispatch(event, obj)
      obj[:event] = event
      @on_event_handlers.each do |e|
        e.call(obj)
      end
    end

    # Event Handler
    class Handler
      def initialize(event, &block)
        @event = event
        @block = block
      end

      def call(obj)
        Thread.new { block.call(obj) } if obj[:event] == event
      end

      attr_reader :event, :block
    end
  end
end
