# frozen_string_literal: true

module CalcFileInfo
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
    permission[8] == 'x' ? 't' : 'T'
  end

  # suid変換
  def calculate_suid(permission)
    permission[2] == 'x' ? 's' : 'S'
  end

  # sgid変換
  def calculate_sgid(permission)
    permission[5] == 'x' ? 's' : 'S'
  end
end
