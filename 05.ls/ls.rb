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
  read_options

  files = []

  sorted_files = sort_file

  sorted_files.each do |file|
    f = File.stat(file)
    file_data = []
    file_data << f.ftype
    file_data << f.mode.to_s(8)
    file_data << f.nlink
    file_data << Etc.getpwuid(f.uid).name
    file_data << Etc.getgrgid(f.gid).name
    file_data << f.size
    file_data << f.mtime.strftime('%_m %e %R')
    file_data << file
    new_file = LS::File.new(file_data)
    files << new_file.dup
  end

  files.reverse! if @o[:r]

  DISP.display(files, @o)
end

def read_options
  opt = OptionParser.new

  @o = {}
  opt.on('-a') { @o[:a] = true } # aオプションを使うと、ファイル名の先頭にピリオドがあるファイルも表示する。
  opt.on('-l') { @o[:l] = true } # 「l」はlongなフォーマットを意味する。longというだけあって詳細を表示して、横長になる。
  opt.on('-r') { @o[:r] = true } # 逆順で表示する。

  opt.parse!(ARGV)
end

def sort_file
  if @o[:a]
    Dir.glob('*', File::FNM_DOTMATCH).sort
  else
    Dir.glob('*').sort
  end
end

module LS
  # 表示するためのファイル情報を保持するクラス
  class File
    attr_accessor :mode, :link, :owner, :group, :size, :time, :name

    def initialize(file_data)
      # lオプションでで必要な情報
      @mode = trans_mode(file_data[0], file_data[1]) # 権限など
      @link = file_data[2] # ハードリンクの数
      @owner = file_data[3] # オーナー名
      @group = file_data[4] # グループ名
      @size = file_data[5] # バイトサイズ
      @time = file_data[6] # タイムスタンプ
      @name = file_data[7] # ファイル名
    end

    def trans_mode(type, mode)
      get_type(type) + get_per(mode)
    end

    #-------ファイル情報取得処理-------

    # ファイルタイプ取得
    def get_type(type)
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
    def get_per(mode)
      # modeの後ろ4桁の数字から特殊権限と通常の権限を取得
      ex_per = mode.to_s[-4]
      abs_per = mode.to_s[-3..]

      sym_per = ''
      abs_per.each_char do |p|
        +sym_per += per_calc(p)
      end

      ex_per_calc(ex_per, sym_per)
    end

    # 各パーミッション変換
    def per_calc(per)
      PERMISSIONS[per]
    end

    def ex_per_calc(special, per)
      case special
      when '1' # stickyのみ
        per[8] = sticky_calc(per)
      when '2' # sgidのみ
        per[5] = sgid_calc(per)
      when '3' # stickyとsgid
        per[8] = sticky_calc(per)
        per[5] = sgid_calc(per)
      when '4' # suidのみ
        per[2] = suid_calc(per)
      when '5' # stickyとsuid
        per[8] = sticky_calc(per)
        per[2] = suid_calc(per)
      when '6' # suidとsgid
        per[5] = sgid_calc(per)
        per[2] = suid_calc(per)
      when '7' # 全部
        all_ex_per(per)
      end
      per
    end

    def all_ex_per(per)
      per[8] = sticky_calc(per)
      per[5] = sgid_calc(per)
      per[2] = suid_calc(per)
    end

    # スティッキービット変換
    def sticky_calc(per)
      if per[8] == 'x'
        't'
      else
        'T'
      end
    end

    # suid変換
    def suid_calc(per)
      if per[2] == 'x'
        's'
      else
        'S'
      end
    end

    # sgid変換
    def sgid_calc(per)
      if per[5] == 'x'
        's'
      else
        'S'
      end
    end
  end
end

#--------表示処理---------

module DISP
  def self.display(files, options)
    if options[:l]
      DISP.display_l(files)
    else
      DISP.display_normal(files)
    end
  end

  # オプションごとの表示方法
  def self.display_l(files)
    files.each do |file|
      puts "#{file.mode} #{file.link} #{file.owner} #{file.group} #{file.size} #{file.time} #{file.name}"
    end
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

#--実行--
main
