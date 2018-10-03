require "open3"

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

          begin
            stdout_and_stderr, status = Open3.capture2e('middleman', 'prismic', '--ref', token)

            if status.success?
              [302, {'Location' => preview_url(token)}, ['Found']]
            else
              [500, {'Location' => '/?error=preview_failure'}, [stdout_and_stderr]]
            end
          rescue Exception => e
            [
              500,
              {'Location' => '/?error=preview_failue'},
              [e.message, "\n\t#{e.backtrace.join("\n\t")}" ]
            ]
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
