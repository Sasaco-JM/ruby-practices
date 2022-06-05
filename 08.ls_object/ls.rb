# frozen_string_literal: true

require './option'
require './format'

class Ls
  # 表示するためのファイル情報を保持するクラス
  def initialize(options)
    @activated_options = options
    @format = Format.new(@activated_options)
  end

  def display
    @format.display
  end
end

def main
  parse = Option.new
  ls = Ls.new(parse.activated_options)
  ls.display
end
# --実行--
main
