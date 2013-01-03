# lib/albedo/middleware.rb
module Albedo
	class Middleware
		def initialize(app)
			@app = app
		end

		def call(env)
			if env["HTTP_AUTHORIZATION"]
				@app.call(env)
			else
				[401, {}, ["Your request failed to include an authorization header.  Check the documentation for more information."]]
			end
		end
	end
end