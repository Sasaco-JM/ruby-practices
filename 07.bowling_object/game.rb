# frozen_string_literal: true

class Game
  attr_reader :frames

  def initialize(game_score)
    @frames = []
    @throw_count = 0
    @one_frame = []

    create_frames(game_score.split(','))
  end

  def score
    total_score = 0
    @frames.each_with_index do |frame, num|
      total_score += calc_score(frame, num)
    end
    total_score
  end

  private

  def create_frames(marks)
    marks.each_with_index do |mark, i|
      if @frames.size < 9 # 最終フレーム以外
        create_frame_exept_last_frame(mark)
      elsif @frames.size == 9 # 最終フレーム
        @one_frame << mark
      end

      @frames << Frame.new(@one_frame[0], @one_frame[1], @one_frame[2]).dup if i == marks.size - 1
    end
  end

  def create_frame_exept_last_frame(mark)
    if mark == 'X' && @throw_count.zero? # 一投目がストライクの場合
      @one_frame.push(mark, 0)
      @throw_count = 1
    else
      @one_frame << mark
    end
    @throw_count += 1

    # ストライクを取るか二投したら次のフレームへ
    return unless @throw_count == 2

    @frames << Frame.new(@one_frame[0], @one_frame[1]).dup
    reset_frame
  end

  def reset_frame
    @one_frame.clear
    @throw_count = 0
  end

  def calc_score(frame, num)
    if num == 9 # ラストフレーム
      frame.score
    elsif frame.first_shot.score == 10 && num == 8 # 9フレーム目でストライクの場合
      10 + @frames[num + 1].first_shot.score + @frames[num + 1].second_shot.score
    elsif frame.first_shot.score == 10 # 8フレーム目までのストライク
      calc_normal_strike_score(num)
    elsif frame.score == 10 && frame.first_shot.score != 10 # スペアの場合
      # 10点に次フレームの一投目を加算
      10 + @frames[num + 1].first_shot.score
    else
      frame.score
    end
  end

  def calc_normal_strike_score(num)
    if @frames[num + 1].first_shot.score == 10
      # 二連続ストライク
      20 + @frames[num + 2].first_shot.score
    else
      # 普通のストライク
      10 + @frames[num + 1].first_shot.score + @frames[num + 1].second_shot.score
    end
  end
end
