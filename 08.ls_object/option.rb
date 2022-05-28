# frozen_string_literal: true

class Option
  # インスタンス変数の参照許可を記載
  attr_reader :activated_options

  def initialize(*options)
    @activated_options = {}
    parse(options)
  end

  private

  def parse(options)
    options&.each do |opt|
      activate_option(opt)
    end
  end

  def activate_option(opt)
    @activated_options[opt.to_sym] = true if %i[a l r].include?(opt.to_sym)
  end
end
