# frozen_string_literal: true

class Ls
  # 表示するためのファイル情報を保持するクラス
  def initialize(*options)
    parse = Parse.new(*options)
    @activated_options = parse.activated_options
    format = Format.new(@activated_options)
    @formated_files = format.files
  end

  # --------表示処理---------
  def display
    if @activated_options[:l]
      display_l
    else
      display_normal
    end
  end

  private

  # オプションごとの表示方法
  def display_l
    @formated_files.each(&:display_file_data)
  end

  def display_normal
    column_count = 3
    f_count = @formated_files.length.to_f
    name_length = 1
    @formated_files.each { |file| name_length = file.name.length if name_length < file.name.length }
    row_count = (f_count / column_count).ceil

    (0...row_count).each do |row|
      (0..column_count).each do |column|
        idx = row_count * column + row
        printf("%-#{name_length}s\t", @formated_files[idx].name) if idx < f_count
      end
      print("\n")
    end
  end
end
