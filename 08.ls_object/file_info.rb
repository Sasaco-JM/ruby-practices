# frozen_string_literal: true

require 'etc'
require './calc_file_info'

class FileInfo
  include CalcFileInfo
  attr_reader :name

  def initialize(file, file_data)
    # lオプションでで必要な情報
    @mode = trans_mode(file_data.ftype, file_data.mode.to_s(8)) # 権限など
    @link = file_data.nlink # ハードリンクの数
    @owner = Etc.getpwuid(file_data.uid).name # オーナー名
    @group = Etc.getgrgid(file_data.gid).name # グループ名
    @size = file_data.size # バイトサイズ
    @time = file_data.mtime.strftime('%_m %e %R') # タイムスタンプ
    @name = file # ファイル名
  end

  # ファイル情報を表示
  def display_file_data
    puts "#{@mode} #{@link} #{@owner} #{@group} #{@size} #{@time} #{@name}"
  end
end
