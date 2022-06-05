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
    %i[a l r].each do |sym|
      opt.on("-#{sym}") { @activated_options[sym] = true }
    end
  end
end
