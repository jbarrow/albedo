require 'spec_helper'

decsribe Albedo::Middleware do
	let(:precipitate) { lambda { |env| [200, {}, []] } }
	let(:middleware) { Albedo::Middleware.new(precipitate) }
	let(:mock_request) { Rack::MockRequest.new(middleware) }

	context "When incoming request has no Authorization header" do
		let(:resp) { mock_request.get("/") }

		it("returns a 401") { resp.status.should == 401 }
		it "notifies the client that they are unauthorized" do
			resp.body.should == "Your request failed to include an authorization header.  Check the documentation for more information."
		end
	end
end