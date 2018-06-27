require "sinatra/base"
require "capybara_discoball"
require "json"
require "ostruct"

class FakePrismic < Sinatra::Base
  MASTER_REF = "MasterRef"

  set :views, Proc.new { File.expand_path("../../fixtures/responses/", __FILE__) }

  @@document = nil

  def self.set_document(id:, type:, ref: MASTER_REF)
    @@document = OpenStruct.new(id: id, type: type, ref: ref)
  end

  def self.reset
    @@document = nil
  end

  get "/" do
    erb "root.json".to_sym
  end

  get "/documents/search" do
    if @@document.ref == params["ref"]
      erb "search.json".to_sym, locals: { document: @@document }
    end
  end
end

RSpec.configure do |config|
  config.after(:each, type: :feature) do
    FakePrismic.reset
  end
end
