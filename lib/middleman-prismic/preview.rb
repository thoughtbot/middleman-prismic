module Middleman
  module Prismic
    class Preview
      def initialize(app, options={})
        @app = app
        @options = options
      end

      def call(env)
        req = ::Rack::Request.new(env)
        if req.path =~ %r(^/preview)
          token = req.params["token"]

          succeeded = Kernel.system 'middleman', 'prismic', '--ref', token
          if succeeded
            [302, {'Location' => preview_url(token)}, ['Found']]
          else
            [500, {'Location' => '/?error=preview_failure'}, ['Error']]
          end
        else
          @app.call(env)
        end
      end

      def preview_url(token)
        if @options[:api_url] && @options[:link_resolver]
          api = ::Prismic.api(@options[:api_url])
          api.preview_session(token, @options[:link_resolver], '/')
        else
          '/'
        end
      end
    end
  end
end
