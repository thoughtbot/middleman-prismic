require 'prismic'
require 'middleman-core'
require 'middleman-prismic/version'
require 'middleman-prismic/commands/prismic'

module Middleman
  module Prismic
    class << self
      attr_reader :options
    end

    class Core < ::Middleman::Extension
      option :api_url, nil, 'The Prismic API URL'
      option :release, 'master', 'Content release'
      option :access_token, nil, 'Access token (optional)'
      option(
        :link_resolver,
        ->(link) {"http://www.example.com/#{link.type.pluralize}/#{link.slug}"},
        'The link resolver'
      )
      option :custom_queries, {}, 'Custom queries'

      def initialize(app, options_hash={}, &block)
        super

        Middleman::Prismic.instance_variable_set('@options', options)
      end

      helpers do
        def reference
          ref = YAML::load(File.read('data/prismic/reference.yml'))
          ref.class.send(
            :define_method, :link_to, Middleman::Prismic.options.link_resolver
          )

          ref
        end
      end
    end
  end
end

::Middleman::Extensions.register(:prismic, Middleman::Prismic::Core)
