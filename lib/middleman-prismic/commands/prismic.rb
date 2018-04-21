require 'middleman-core/cli'
require 'yaml'
require 'fileutils'

module Middleman
  module Cli
    class Prismic < Thor::Group
      # Path where Middleman expects the local data to be stored
      DATA_DIR = 'data/prismic'.freeze

      check_unknown_options!

      namespace :prismic
      desc 'Import data from Prismic'

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def prismic
        create_directories
        paginate_available_documents
        output_references
        output_custom_queries
      end

      private

      def create_directories
        if File.exists?(DATA_DIR)
          FileUtils.rm_rf(Dir.glob(DATA_DIR))
        end

        FileUtils.mkdir_p(DATA_DIR)
      end

      def paginate_available_documents
        page = 0

        begin
          page += 1
          api_form.page(page)
          response = api_response(api_form)

          output_available_documents(response)
        end while page < response.total_pages
      end

      def output_available_documents(response)
        response.group_by(&:type).each do |document_type, documents|
          document_dir = File.join(DATA_DIR, document_type.pluralize)
          write_collection(document_dir, documents)
        end
      end

      def output_references
        File.open(File.join(DATA_DIR, 'reference.yml'), 'w') do |f|
          f.write(api.master_ref.to_yaml)
        end
      end

      def output_custom_queries
        Middleman::Prismic.options.custom_queries.each do |key, value|
          document_dir = File.join(DATA_DIR, "custom_#{key}")
          response = api.form('everything').query(*value).submit(api.master_ref)
          write_collection(document_dir, response)
        end
      end

      def api_response(form)
        form.submit(api_reference)
      end

      def api_form
        @api_form ||= api.form('everything')
      end

      def api_reference
        api.ref(Middleman::Prismic.options.release)
      end

      def api
        @api ||= ::Prismic.api(Middleman::Prismic.options.api_url, Middleman::Prismic.options.access_token)
      end

      def write_collection(dir, collection)
        FileUtils.mkdir_p(dir)

        collection.each do |item|
          File.open(File.join(dir, "#{item.id}.yml"), 'w') do |file|
            file.write(item.to_yaml)
          end
        end
      end

      Base.register(self, 'prismic', 'prismic [options]', 'Get data from Prismic')
    end
  end
end
