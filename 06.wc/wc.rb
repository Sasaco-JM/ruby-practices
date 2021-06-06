#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = {}
  files = []
  total_data = { lines: 0, words: 0, bytes: 0 }

  WC.check_options(options)

  if FileTest.pipe?($stdin)
    stdin = $stdin.read
    WC.display_stdin(stdin, options)
  elsif !ARGV.empty?
    ARGV.each do |file|
      files << WC::File.new(file, File.read(file))
    end

    WC.display_files_data(files, options)

    WC.display_total(files, options, total_data)
  else
    stdin = $stdin.read
    WC.display_stdin(stdin, options)
  end
end

module WC
  class File
    attr_reader :name, :lines, :words, :bytes

    def initialize(file, file_data)
      @name = file
      @lines = file_data.count("\n")
      @words = file_data.split(/[\s　]+/).size
      @bytes = file_data.bytesize
    end

    def display_file_data
      print @lines.to_s.rjust(8)
      print @words.to_s.rjust(8)
      print @bytes.to_s.rjust(8)
      print @name.to_s.rjust(@name.length + 1)
      puts
    end

    def display_file_data_l
      print @lines.to_s.rjust(8)
      print @name.to_s.rjust(@name.length + 1)
      puts
    end
  end

  #----------オプション処理---------
  def self.check_options(options)
    opt = OptionParser.new
    opt.on('-l') { options[:l] = true }
    opt.parse!(ARGV)
  end

  # ----------行、単語、byte数の表示用----------

  def self.display_files_data(files, options)
    files.each do |file|
      if options[:l]
        file.display_file_data_l
      else
        file.display_file_data
      end
    end
  end

  def self.display_total(files, options, total_data)
    if files.size > 1 && !options[:l]
      WC.count_total_data(files, total_data)
      WC.create_line(total_data)
    elsif files.size > 1 && options[:l]
      WC.count_total_data_l(files, total_data)
      WC.create_line_l(total_data)
    end
  end

  def self.count_total_data(files, total_data)
    files.each do |file|
      total_data[:lines] += file.lines
      total_data[:words] += file.words
      total_data[:bytes] += file.bytes
    end
  end

  def self.count_total_data_l(files, total_data)
    files.each do |file|
      total_data[:lines] += file.lines
    end
  end

  def self.create_line(total_data)
    print total_data[:lines].to_s.rjust(8)
    print total_data[:words].to_s.rjust(8)
    print total_data[:bytes].to_s.rjust(8)
    print 'total'.rjust(6)
    puts
  end

  def self.create_line_l(total_data)
    print total_data[:lines].to_s.rjust(8)
    print 'total'.rjust(6)
    puts
  end

  # 標準入力,pipe表示用
  def self.display_stdin(stdin, options)
    if options[:l]
      create_stdin_line_l(stdin)
    else
      create_stdin_line(stdin)
    end
  end

  def self.create_stdin_line(stdin)
    print stdin.count("\n").to_s.rjust(8)
    print stdin.split(/[\s　]+/).size.to_s.rjust(8)
    print stdin.bytesize.to_s.rjust(8)
    puts
  end

  def self.create_stdin_line_l(stdin)
    print stdin.count("\n").to_s.rjust(8)
    puts
  end
end

main
