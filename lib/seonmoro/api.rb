module LastMinute

  # This module provides the core implementation of the SeOnMoro HTTP service.
  class API
    attr_accessor :auth_options

    class << self

      def authenticate(api_id, username, password)
        api = self.new
        session_id = api.authenticate(api_id, username, password)
        api.auth_options = {:session_id => session_id}
        api
      end

      attr_accessor :debug_mode
      attr_accessor :secure_mode
      attr_accessor :api_service_host
    end

    self.debug_mode = true
    self.secure_mode = false

    def initialize(auth_options={})
      @auth_options = auth_options
    end

    # Authenticates using the specified credentials. Returns
    # a session_id if successful which can be used in subsequent
    # API calls.
    def authenticate(api_id, username, password)
      @api_id = api_id
      @username = username
      @password = password

      # TODO: session_id

    end

  end
end
