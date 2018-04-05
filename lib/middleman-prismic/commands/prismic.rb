require 'middleman-core/cli'
require 'yaml'
require 'fileutils'

module Middleman
  module Cli
    class Prismic < Thor::Group
      # Path where Middleman expects the local data to be stored
      DATA_DIR = 'data'

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
        output_available_documents
        output_references
        output_custom_queries
      end

      private

      def create_directories
        if File.exists?("#{DATA_DIR}/prismic")
          FileUtils.rm_rf(Dir.glob("#{DATA_DIR}/prismic"))
        end

        Dir.mkdir("#{DATA_DIR}") unless File.exists?("#{DATA_DIR}")
        Dir.mkdir("#{DATA_DIR}/prismic")
      end

      def output_available_documents
        api_response.map(&:type).uniq.each do |document_type|
          document_dir = "#{DATA_DIR}/prismic/#{document_type.pluralize}"
          documents = api_response.select { |d| d.type == document_type }
          write_collection(document_dir, documents)
        end
      end

      def output_references
        File.open("#{DATA_DIR}/prismic/reference.yml", "w") do |f|
          f.write(api.master_ref.to_yaml)
        end
      end

      def output_custom_queries
        Middleman::Prismic.options.custom_queries.each do |key, value|
          document_dir = "#{DATA_DIR}/prismic/custom_#{key}"
          response = api.form("everything").query(*value).submit(api.master_ref)
          write_collection(document_dir, response)
        end
      end

      def api_response
        @api_response ||= api.form('everything').submit(api_reference)
      end

      def api_reference
        api.ref(Middleman::Prismic.options.release)
      end

      def api
        @api ||= ::Prismic.api(Middleman::Prismic.options.api_url)
      end

      def write_collection(dir, collection)
        Dir.mkdir(dir) unless File.exists?(dir)

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
