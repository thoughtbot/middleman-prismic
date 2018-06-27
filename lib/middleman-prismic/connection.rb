module Middleman
  module Prismic
    class Connection
      def initialize(
        api_url:,
        access_token: nil,
        custom_queries: [],
        link_resolver: nil,
        prismic_class: ::Prismic,
        ref: nil,
        release: "master"
      )
        @api_url = api_url
        @access_token = nil,
        @custom_queries = custom_queries
        @ref = ref
        @release = release
        @prismic_class = prismic_class
      end

      def documents
        page = 0

        begin
          page += 1
          api_form.page(page)
          response = api_response(api_form)

          if block_given?
            yield response
          end
        end while page < response.total_pages
      end

      def master_ref_yaml
        api.master_ref.to_yaml
      end

      def run_custom_queries
        custom_queries.each do |key, value|
          response = api.form('everything').query(*value).submit(api.master_ref)
          yield(key, response)
        end
      end

      private

      attr_reader(
        :api_url,
        :access_token,
        :custom_queries,
        :link_resolver,
        :prismic_class,
        :ref,
        :release,
      )

      def api_response(form)
        form.submit(api_reference)
      end

      def api_form
        @api_form ||= api.form('everything')
      end

      def api_reference
        ref || api.ref(release)
      end

      def api
        @_api ||= prismic_class.api(api_url, access_token.first)
      end
    end
  end
end
