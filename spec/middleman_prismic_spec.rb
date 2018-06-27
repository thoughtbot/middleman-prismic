require "spec_helper"

describe MiddlemanPrismic do
  describe "download from prismic", :in_temp_directory do
    it "downloads content from prismic and installs in directory" do
      Capybara::Discoball.spin(FakePrismic) do |server|
        write_prismic_configuration(server)
        FakePrismic.set_document(id: "referoo", type: "demo-test")

        `middleman prismic`

        hex_string = Digest::MD5.hexdigest("referoo")
        document = YAML.load_file("data/prismic/demo-tests/#{hex_string}.yml")

        expect(document.id).to eq "referoo"
      end
    end

    it "downloads content from prismic by reference" do
      Capybara::Discoball.spin(FakePrismic) do |server|
        write_prismic_configuration(server)
        FakePrismic.set_document(id: "referoo", type: "demo-test", ref: "someref")

        `middleman prismic --ref someref`

        hex_string = Digest::MD5.hexdigest("referoo")
        document = YAML.load_file("data/prismic/demo-tests/#{hex_string}.yml")

        expect(document.id).to eq "referoo"
      end
    end
  end

  def write_prismic_configuration(server)
    File.open("config.rb", "w") do |file|
      file.write <<~RUBY
        activate :prismic do |f|
          f.api_url = "#{server.url}"
        end
      RUBY
    end
  end
end
