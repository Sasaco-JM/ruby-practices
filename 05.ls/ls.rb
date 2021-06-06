#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

# パーミッション変換のための定数定義
PERMISSIONS = {
  '0' => '---',
  '1' => '--x',
  '2' => '-w-',
  '3' => '-wx',
  '4' => 'r--',
  '5' => 'r-x',
  '6' => 'rw-',
  '7' => 'rwx'
}.freeze

def main
  options = {}
  read_options(options)
  files = []

  lined_up_files = line_up_files(options)

  lined_up_files.each do |file|
    file_data = File.stat(file)
    new_file = LS::File.new(file, file_data)
    files << new_file
  end

  LS.display(files, options)
end

def read_options(options)
  opt = OptionParser.new

  opt.on('-a') { options[:a] = true } # aオプションを使うと、ファイル名の先頭にピリオドがあるファイルも表示する。
  opt.on('-l') { options[:l] = true } # 「l」はlongなフォーマットを意味する。longというだけあって詳細を表示して、横長になる。
  opt.on('-r') { options[:r] = true } # 逆順で表示する。

  opt.parse!(ARGV)
end

def line_up_files(options)
  files = if options[:a]
            Dir.glob('*', File::FNM_DOTMATCH).sort
          else
            Dir.glob('*').sort
          end
  options[:r] ? files.reverse! : files
end

module LS
  # 表示するためのファイル情報を保持するクラス
  class File
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

    def trans_mode(type, mode)
      convert_file_type(type) + specify_permission(mode)
    end

    # -------ファイル情報取得処理-------

    # ファイルタイプ取得
    def convert_file_type(type)
      case type
      when 'fifo'
        'p'
      when 'characterSpecial'
        'c'
      when 'directory'
        'd'
      when 'blockSpecial'
        'b'
      when 'file'
        '-'
      when 'link'
        'l'
      when 'socket'
        's'
      else
        'error'
      end
    end

    # パーミッション取得
    def specify_permission(mode)
      # modeの後ろ4桁の数字から特殊権限と通常の権限を取得
      ex_permission = mode.to_s[-4]
      absolute_permission = mode.to_s[-3..]

      symbolic_permission = ''
      absolute_permission.each_char do |per|
        +symbolic_permission += calculate_permission(per)
      end

      calculate_ex_permission(ex_permission, symbolic_permission)
    end

    # 各パーミッション変換
    def calculate_permission(permission)
      PERMISSIONS[permission]
    end

    def calculate_ex_permission(special, permission)
      case special
      when '1' # stickyのみ
        permission[8] = calculate_sticky(permission)
      when '2' # sgidのみ
        permission[5] = calculate_sgid(permission)
      when '3' # stickyとsgid
        permission[8] = calculate_sticky(permission)
        permission[5] = calculate_sgid(permission)
      when '4' # suidのみ
        permission[2] = calculate_suid(permission)
      when '5' # stickyとsuid
        permission[8] = calculate_sticky(permission)
        permission[2] = calculate_suid(permission)
      when '6' # suidとsgid
        permission[5] = calculate_sgid(permission)
        permission[2] = calculate_suid(permission)
      when '7' # 全部
        calculate_all_ex_permission(permission)
      end
      permission
    end

    def calculate_all_ex_permission(permission)
      per[8] = calculate_sticky(permission)
      per[5] = calculate_sgid(permission)
      per[2] = calculate_suid(permission)
    end

    # スティッキービット変換
    def calculate_sticky(permission)
      if permission[8] == 'x'
        't'
      else
        'T'
      end
    end

    # suid変換
    def calculate_suid(permission)
      if permission[2] == 'x'
        's'
      else
        'S'
      end
    end

    # sgid変換
    def calculate_sgid(permission)
      if permission[5] == 'x'
        's'
      else
        'S'
      end
    end
  end

  # --------表示処理---------

  def self.display(files, options)
    if options[:l]
      LS.display_l(files)
    else
      LS.display_normal(files)
    end
  end

  # オプションごとの表示方法
  def self.display_l(files)
    files.each(&:display_file_data)
  end

  def self.display_normal(files)
    column_count = 3
    f_count = files.length.to_f
    name_length = 1
    files.each { |file| name_length = file.name.length if name_length < file.name.length }
    row_count = (f_count / column_count).ceil

    (0...row_count).each do |row|
      (0..column_count).each do |column|
        idx = row_count * column + row
        printf("%-#{name_length}s\t", files[idx].name) if idx < f_count
      end
      print("\n")
    end
  end
end

# --実行--
main
