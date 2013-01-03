# lib/albedo/request
module Albedo
	class Request < Rack::Auth::AbstractRequest
		# The following method uses Rack's abstract request to parse the header
		# and verify the header.
		#
		def with_valid_request
			if provided?
				if !oauth?
					[401, {}, "The Authorization header on was not OAuth.  Check the documentation for more information."]
				elsif params[:consumer_key].nil?
					[401, {}, "The Authorization header on your request lacked your consumer key.  Check the documentation for more information."]
				elsif params[:signature].nil?
					[401, {}, "You failed to sign the request.  Check the documentation for more information."]
				elsif params[:signature_method].nil?
					[401, {}, "Your request did not have a signature method.  It must be HMAC-SHA1.  Check the documentation for more information."]
				else
					yield(request.env)
				end
			else
				[401, {}, ["Your request failed to include an authorization header.  Check the documentation for more information."]]
			end
		end

		def verify_signature(client)
			return false unless client

			header = SimpleOAuth::Header.new(request.request_method, request.url, included_request_params, auth_header)
			header.valid?(:consumer_secret => client.consumer_secret)
		end

		def consumer_key
			params[:consumer_key]
		end

		private

		def params
			@params ||= SimpleOAuth::Header.parse(auth_header)
		end

		def oauth?
			scheme == :oauth
		end

		def auth_header
			@env[authorization_key]
		end

		# only include request params if Content-Type is set to application/x-www/form-urlencoded
		# (see http://tools.ietf.org/html/rfc5849#section-3.4.1)
		#
		def included_request_params
			request.content_type == "application/x-www-form-urlencoded" ? request.params : nil
		end
	end
end