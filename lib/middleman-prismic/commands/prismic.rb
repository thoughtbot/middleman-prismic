require 'middleman-core/cli'
require 'yaml'
require 'fileutils'

module Middleman
  module Cli

    class Prismic < Thor::Group
      # Path where Middleman expects the local data to be stored
      MIDDLEMAN_LOCAL_DATA_FOLDER = 'data'

      check_unknown_options!

      namespace :prismic
      desc 'Import data from Prismic'

=begin
      method_option "refetch",
        aliases: "-r",
        desc: "Refetches the data from Prismic"
=end

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      def prismic
        # ::Middleman::Application.server.inst
        reference = Middleman::Prismic.options.release

        Dir.mkdir('data') unless File.exists?('data')

        Dir.mkdir('data/prismic') unless File.exists?('data/prismic')

        FileUtils.rm_rf(Dir.glob('data/prismic_*'))

        api = ::Prismic.api(Middleman::Prismic.options.api_url)
        response = api.form('everything').submit(api.ref(reference))

        available_documents = []
        response.each {|d| available_documents << d.type}

        available_documents.uniq!

        available_documents.each do |document_type|
          document_dir = "data/prismic/#{document_type.pluralize}"
          Dir.mkdir(document_dir) unless File.exists?(document_dir)
          File.delete(*Dir.glob("#{document_dir}/*.yml"))

          documents = response.select{|d| d.type == document_type}

          documents.each do |document|
            File.open(File.join(document_dir, "#{document.id}.yml"), 'w') do |f|
              f.write(document.to_yaml)
            end
          end
        end

        File.open('data/prismic/reference.yml', 'w') do |f|
          f.write(api.master_ref.to_yaml)
        end

        Middleman::Prismic.options.custom_queries.each do |k, v|
          response = api.form('everything').query(*v).submit(api.master_ref)
          File.open("data/prismic/custom_#{k}.yml", 'w') do |f|
            f.write(Hash[[*response.map.with_index]].invert.to_yaml)
          end
        end
      end

      Base.register(self, 'prismic', 'prismic [options]', 'Get data from Prismic')
    end
  end
end
