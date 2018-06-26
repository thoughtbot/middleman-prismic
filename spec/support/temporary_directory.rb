require "tmpdir"

class TemporaryDirectory
  def create_and_move_to_temporary_directory
    Dir.mktmpdir do |directory|
      Dir.chdir(directory) do
        yield(directory)
      end
    end
  end
end


RSpec.configure do |config|
  config.around(in_temp_directory: true) do |example|
    TemporaryDirectory.new.create_and_move_to_temporary_directory do |directory|
      example.metadata[:directory] = directory
      example.run
    end
  end
end
