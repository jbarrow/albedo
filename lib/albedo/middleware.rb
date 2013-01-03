# lib/albedo/middleware.rb
require 'albedo/request'

module Albedo
	class Middleware
		def initialize(app)
			@app = app
		end

		def call(env)
			@request = Request.new(env)

			@request.with_valid_request do
				if client_verified?
					env["oauth_client"] = @client
					@app.call(env)
				else
					[401, {}, ["Your request included invalid credentials."]]
				end
			end
		end

		private

		def client_verified?
			@client = Client.find_by_consumer_key(@request.consumer_key)
			@request.verify_signature(@client)
		end
	end
end