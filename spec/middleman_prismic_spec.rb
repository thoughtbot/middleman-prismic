require "spec_helper"

describe MiddlemanPrismic do
  describe "download from prismic", :in_temp_directory do
    it "downloads content from prismic and installs in directory" do |example|
      Capybara::Discoball.spin(FakePrismic) do |server|
        directory = example.metadata[:directory]
        FakePrismic.set_document(id: "referoo", type: "demo-test")
        change_directory_and_configure_with_prismic(directory, server)

        run_middleman_prismic

        hex_string = Digest::MD5.hexdigest("referoo")
        document = YAML.load_file("data/prismic/demo-tests/#{hex_string}.yml")

        expect(document.id).to eq "referoo"
      end
    end
  end

  def change_directory_and_configure_with_prismic(directory, server)
    File.open("config.rb", "w") do |file|
      file.write <<~RUBY
        activate :prismic do |f|
          f.api_url = "#{server.url}"
        end
      RUBY
    end
  end

  def run_middleman_prismic
    `middleman prismic`
  end
end
