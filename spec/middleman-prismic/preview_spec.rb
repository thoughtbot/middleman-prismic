require "spec_helper"
require "middleman-prismic/preview"
require "open3"

describe Middleman::Prismic::Preview do
  it "passes through requests outside of /preview" do
    stub_system
    expected_response = double(:expected_response)
    app = rack_app(response: expected_response)
    request = env_for("http://example.com/")

    middleware = Middleman::Prismic::Preview.new(app)
    response = middleware.call request

    expect(Open3).not_to have_received(:capture2e)
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

      expect(Open3).to have_received(:capture2e).
        with("middleman", "prismic", "--ref", "foo bar token")
      expect(message).to respond_to(:each)
    end

    it "redirects to the requested page" do
      stub_system
      app = rack_app
      request = env_for("http://example.com/preview?token=foo%20bar%20token")
      api_url = 'http://prismic.url'
      link_resolver = double(:link_resolver)
      prismic_spy = spy(Prismic, preview_session: '/foobar')
      allow(Prismic).to receive(:api) { prismic_spy }

      middleware = Middleman::Prismic::Preview.new(
        app,
        api_url: api_url,
        link_resolver: link_resolver,
      )
      code, headers, message = middleware.call request

      expect(Prismic).to have_received(:api).with(api_url)
      expect(prismic_spy).to have_received(:preview_session)
      expect(code).to eq 302
      expect(headers).to include 'Location' => '/foobar'
    end

    context "when the request fails" do
      it "returns a 500" do
        stub_system(success: false)
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

  def stub_system(success: true)
    stdout_and_stderr = ""
    exit_status = double(:exit_status, success?: success)
    allow(Open3).to receive(:capture2e).and_return(
      [stdout_and_stderr, exit_status]
    )
  end
end
