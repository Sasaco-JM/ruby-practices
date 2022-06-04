# frozen_string_literal: true

require 'optparse'

class Option
  # インスタンス変数の参照許可を記載
  attr_reader :activated_options

  def initialize
    @activated_options = {}
    parse
  end

  private

  def parse
    opt = OptionParser.new
    activate_option(opt)
    opt.parse!(ARGV)
  end

  def activate_option(opt)
    opt.on('-a') { @activated_options[:a] = true } # aオプションを使うと、ファイル名の先頭にピリオドがあるファイルも表示する。
    opt.on('-l') { @activated_options[:l] = true } # 「l」はlongなフォーマットを意味する。longというだけあって詳細を表示して、横長になる。
    opt.on('-r') { @activated_options[:r] = true } # 逆順で表示する。
  end
end
