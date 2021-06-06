#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]

scores = score.split(',')

shots = []
scores.each do |s|
  shots << if s == 'X' # ストライク
             10
           else
             s.to_i
           end
end

# フレームごとにスコアを分けて配列に格納
frames = []
one_frame = []
frame_count = 0
throw_count = 0

shots.each_with_index do |s, i|
  if frame_count < 9 # 最終フレーム以外
    if s == 10 && throw_count.zero? # 一投目が10点の場合
      one_frame.push(s, 0)
      throw_count = 1
    else
      one_frame << s
    end
    throw_count += 1
    if throw_count == 2 # ストライクを取るか二投したら次のフレームへ
      frames << one_frame.dup
      one_frame.clear
      throw_count = 0
      frame_count += 1
    end
  elsif frame_count == 9 # 最終フレーム
    one_frame << s
  end

  frames << one_frame.dup if i == shots.size - 1
end

# スコア計算
point = 0
frames.each_with_index do |frame, i|
  point += if i == 9 # ラストフレーム
             frame.sum
           elsif frame[0] == 10 && i == 8 # ラストフレーム以外
             10 + frames[i + 1][0] + frames[i + 1][1] # 9フレーム目でストライクの場合
           elsif frame[0] == 10 # 8フレーム目までのストライク
             if frames[i + 1][0] == 10
               # 二連続ストライク
               20 + frames[i + 2][0]
             else
               # 普通のストライク
               10 + frames[i + 1][0] + frames[i + 1][1]
             end
           elsif frame.sum == 10 && frame[0] != 10 # スペアの場合
             # 10点に次フレームの一投目を加算
             10 + frames[i + 1][0]
           else
             frame.sum
           end
end

puts point
