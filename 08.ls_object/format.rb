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

    @files = lined_up_files&.map do |file|
      file_data = File.stat(file)
      FileInfo.new(file, file_data)
    end
  end

  def line_up_files
    glob_params = ['*']
    glob_params << File::FNM_DOTMATCH if @options[:a]
    files = Dir.glob(*glob_params).sort

    @options[:r] ? files.reverse! : files
  end

  # オプションごとの表示方法
  def display_l
    @files.each(&:display_file_data)
  end

  def display_normal
    column_count = 3
    f_count = @files.length.to_f
    name_length = 1
    @files.each { |file| name_length = file.name.length if name_length < file.name.length }
    row_count = (f_count / column_count).ceil

    (0...row_count).each do |row|
      (0..column_count).each do |column|
        idx = row_count * column + row
        printf("%-#{name_length}s\t", @files[idx].name) if idx < f_count
      end
      print("\n")
    end
  end
end
