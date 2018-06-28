require "spec_helper"
require "middleman-prismic/preview"

describe Middleman::Prismic::Preview do
  it "passes through requests outside of /preview" do
    stub_system
    expected_response = double(:expected_response)
    app = rack_app(response: expected_response)
    request = env_for("http://example.com/")

    middleware = Middleman::Prismic::Preview.new(app)
    response = middleware.call request

    expect(Kernel).not_to have_received(:system)
    expect(app).to have_received(:call).with(request)
    expect(response).to be expected_response
  end

  context "given a request to /preview" do
    it "intercepts the request" do
      stub_system
      app = rack_app
      request = env_for("http://example.com/preview")

      middleware = Middleman::Prismic::Preview.new(app)
      code, headers, message = middleware.call request

      expect(code).to eq 302
      expect(message).to respond_to(:each)
    end

    it "fetches the prismic content for the ref" do
      stub_system
      app = rack_app
      request = env_for("http://example.com/preview?token=foo%20bar%20token")

      middleware = Middleman::Prismic::Preview.new(app)
      code, headers, message = middleware.call request

      expect(Kernel).to have_received(:system).
        with("middleman", "prismic", "--ref", "foo bar token")
      expect(message).to respond_to(:each)
    end

    context "when the request fails" do
      it "returns a 500" do
        stub_system(exit_status: false)
        app = rack_app
        request = env_for("http://example.com/preview")

        middleware = Middleman::Prismic::Preview.new(app)
        code, headers, message = middleware.call request

        expect(code).to eq 500
      end
    end
  end

  private

  def rack_app(response: [200, {"Content-Type" => "text/plain"}, ["OK"]])
    spy(:rack_app, call: response)
  end

  def env_for(url)
    Rack::MockRequest.env_for(url)
  end

  def stub_system(exit_status: true)
    allow(Kernel).to receive(:system).and_return(exit_status)
  end
end
