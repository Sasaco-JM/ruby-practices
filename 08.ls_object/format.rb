# frozen_string_literal: true

class Format
  attr_reader :files

  def initialize(options)
    @files = []
    @options = options
    format
  end

  def format
    lined_up_files = line_up_files

    lined_up_files&.each do |file|
      file_data = File.stat(file)
      new_file = FileInfo.new(file, file_data)
      @files << new_file
    end
  end

  def line_up_files
    files = if @options[:a]
              Dir.glob('*', File::FNM_DOTMATCH).sort
            else
              Dir.glob('*').sort
            end
    @options[:r] ? files.reverse! : files
  end
end
