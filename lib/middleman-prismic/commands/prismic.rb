require "middleman-core/cli"
require "middleman-prismic/connection"
require "yaml"
require "fileutils"
require "digest"

module Middleman
  module Cli
    class Prismic < Thor::Group
      # Path where Middleman expects the local data to be stored
      DATA_DIR = 'data/prismic'.freeze

      class_option(
        :ref,
        type: :string,
        desc: "Pull content from Prismic by ref instead of configured release",
      )

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

      def prismic_connection
        @_prismic_connection ||=
          Middleman::Prismic::Connection.new(combined_prismic_options)
      end

      def combined_prismic_options
        Middleman::Prismic.options.to_h.merge(options)
      end

      def create_directories
        if File.exists?(DATA_DIR)
          FileUtils.rm_rf(Dir.glob(DATA_DIR))
        end

        FileUtils.mkdir_p(DATA_DIR)
      end

      def paginate_available_documents
        prismic_connection.documents do |response|
          output_available_documents(response)
        end
      end

      def output_available_documents(response)
        response.group_by(&:type).each do |document_type, documents|
          document_dir = File.join(DATA_DIR, document_type.pluralize)
          write_collection(document_dir, documents)
        end
      end

      def output_references
        File.open(File.join(DATA_DIR, 'reference.yml'), 'w') do |f|
          f.write(prismic_connection.master_ref_yaml)
        end
      end

      def output_custom_queries
        prismic_connection.run_custom_queries do |name, response|
          document_dir = File.join(DATA_DIR, "custom_#{name}")
          write_collection(document_dir, response)
        end
      end

      def write_collection(dir, collection)
        FileUtils.mkdir_p(dir)

        collection.each do |item|
          filename = "#{Digest::MD5.hexdigest(item.id)}.yml"

          File.write(
            File.join(dir, filename),
            item.to_yaml
          )
        end
      end

      Base.register(self, 'prismic', 'prismic [options]', 'Get data from Prismic')
    end
  end
end
