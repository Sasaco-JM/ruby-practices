# frozen_string_literal: true

require './file_info'

class Format
  attr_reader :files

  def initialize(options)
    @files = []
    @options = options
    organize_files
  end

  def organize_files
    lined_up_files = line_up_files

    @files = lined_up_files&.map do |file|
      file_data = File.stat(file)
      FileInfo.new(file, file_data)
    end
  end

  def line_up_files
    files = Dir.glob('*', @options[:a] ? File::FNM_DOTMATCH : 0).sort

    @options[:r] ? files.reverse! : files
  end

  # --------表示処理---------
  def display
    if @options[:l]
      display_l
    else
      display_normal
    end
  end

  def display_l
    @files.each(&:display_file_data)
  end

  def display_normal
    column_count = 3
    f_count = @files.length.to_f
    name_length = 1
    @files.each { |file| name_length = file.name.length if name_length < file.name.length }
    row_count = (f_count / column_count).ceil

    row_count.times do |row|
      column_count.times do |column|
        idx = row_count * column + row
        printf("%-#{name_length}s\t", @files[idx].name) if idx < f_count
      end
      print("\n")
    end
  end
end
