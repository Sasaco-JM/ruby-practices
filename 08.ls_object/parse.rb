# frozen_string_literal: true

class Parse
  # インスタンス変数の参照許可を記載
  attr_reader :activated_options

  def initialize(*options)
    @activated_options = {}
    read_options(options)
  end

  private

  def read_options(options)
    options&.each do |opt|
      activate_option(opt)
    end
  end

  def activate_option(opt)
    case opt
    when 'a'
      @activated_options[:a] = true # aオプションを使うと、ファイル名の先頭にピリオドがあるファイルも表示する。
    when 'l'
      @activated_options[:l] = true  # 「l」はlongなフォーマットを意味する。longというだけあって詳細を表示して、横長になる。
    when 'r'
      @activated_options[:r] = true  # 逆順で表示する。
    else
      true
    end
  end
end
