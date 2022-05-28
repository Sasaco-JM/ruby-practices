# frozen_string_literal: true

class Ls
  # 表示するためのファイル情報を保持するクラス
  def initialize(*options)
    parse = Option.new(*options)
    @activated_options = parse.activated_options
    @format = Format.new(@activated_options)
  end

  # --------表示処理---------
  def display
    if @activated_options[:l]
      @format.display_l
    else
      @format.display_normal
    end
  end
end
