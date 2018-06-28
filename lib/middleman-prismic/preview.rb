module Middleman
  module Prismic
    class Preview
      def initialize(app, options={})
        @app = app
      end

      def call(env)
        req = ::Rack::Request.new(env)
        if req.path =~ %r(^/preview)
          token = req.params["token"]

          succeeded = Kernel.system "middleman", "prismic", "--ref", token
          if succeeded
            [302, {'Location' => '/'}, ['Found']]
          else
            [500, {'Location' => '/?error=preview_failure'}, ['Error']]
          end
        else
          @app.call(env)
        end
      end
    end
  end
end
