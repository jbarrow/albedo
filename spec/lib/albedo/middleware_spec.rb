require 'spec_helper'

describe Albedo::Middleware do
	let(:precipitate) { lambda { |env| [200, {}, []] } }
	let(:middleware) { Albedo::Middleware.new(precipitate) }
	let(:mock_request) { Rack::MockRequest.new(middleware) }

	context "when incoming request has no Authorization header" do
		let(:resp) { mock_request.get("/") }

		it("returns a 401") { resp.status.should == 401 }
		it "notifies the client that they are unauthorized" do
			resp.body.should == "Your request failed to include an authorization header.  Check the documentation for more information."
		end
	end

	context "when incoming request has an Authorization header" do
		context "but is missing an OAuth Authorization scheme" do
			let(:header_with_bad_scheme) {{ "HTTP_AUTHORIZATION" => "Force" }}
			let(:resp) { mock_request.get("/", header_with_bad_scheme) }

			it("returns a 401") { resp.status.should == 401 }
			it "notifies the client that they sent the wrong authorization scheme" do
				resp.body.should == "The Authorization header on was not OAuth.  Check the documentation for more information."
			end
		end

		context "but it is missing an oauth_consumer_key" do
			let(:header_with_no_key) {{ "HTTP_AUTHORIZATION" => "OAuth realm=\"Client\"" }}
			let(:resp) { mock_request.get("/", header_with_no_key) }

			it("returns a 401") { resp.status.should == 401 }
			it "notifies the client that they omitted the consumer key" do
				resp.body.should == "The Authorization header on your request lacked your consumer key.  Check the documentation for more information."
			end
		end

		context "but it is missing an oauth_signature" do
			let(:header_with_no_signature) {{ "HTTP_AUTHORIZATION" => "OAuth realm=\"Client\", oauth_consumer_key=\"123\"" }}
			let(:resp) { mock_request.get("/", header_with_no_signature) }

			it("returns a 401") { resp.status.should == 401 }
			it "notifies the client that they omitted the signature" do
				resp.body.should == "You failed to sign the request.  Check the documentation for more information."
			end
		end

		context "but it is missing the oauth_signature_method" do
			let(:header_with_no_signature) {{ "HTTP_AUTHORIZATION" => "OAuth realm=\"Client\", oauth_consumer_key=\"123\", oauth_signature=\"SIGNATURE\"" }}
			let(:resp) { mock_request.get("/", header_with_no_signature) }

			it("returns a 401") { resp.status.should == 401 }
			it "notifies the client that they omitted the signature method" do
				resp.body.should == "Your request did not have a signature method.  It must be HMAC-SHA1.  Check the documentation for more information."
			end
		end
	end

	context "client makes request with sufficient, but incorrect, OAuth header" do
		let(:test_uri) { "http://precipitate.io/api/v1.0" }
		let(:incorrect_secret) { "!!badsecret!!" }
		let(:bad_consumer_credentials) {{ consumer_key: Client::DUMMY_KEY, consumer_secret: incorrect_secret }}
		let(:invalid_auth_header) {{ "HTTP_AUTHORIZATION" => SimpleOAuth::Header.new(:get, test_uri, {}, bad_consumer_credentials).to_s }}
		let(:resp) { mock_request.get(test_uri, invalid_auth_header) }
		let(:client_with_good_credentials) { Client.new(Client::DUMMY_KEY, Client::DUMMY_SECRET) }

		before { Client.stub(:find_by_consumer_key).and_return(client_with_good_credentials) }

		it("returns a 401") { resp.status.should == 401 }
		it "notifies the client that they have provided the incorrect credentials" do
			resp.body.should == "Your request included invalid credentials."
		end
	end
end