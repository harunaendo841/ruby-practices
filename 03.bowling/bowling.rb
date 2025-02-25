#!/usr/bin/env ruby
# frozen_string_literal: true

TOTAL_FRAMES   = 10
PINS_PER_FRAME = 10

def abort_with_message(msg = 'スコアを入力してください')
  abort(msg)
end

abort_with_message if ARGV.empty?

input = ARGV.join(',')
shots = input.split(',')

shot_values = shots.map do |s|
  next PINS_PER_FRAME if s == 'X'

  Integer(s, exception: false) || abort_with_message("エラー: 不正なスコア入力: #{s}")
end

def calculate_score(shot_values)
  score = 0
  index = 0

  (1..TOTAL_FRAMES).each do |frame|
    if frame == TOTAL_FRAMES
      score += shot_values[index, 3].compact.sum
      break
    end

    if strike?(shot_values[index])
      score += PINS_PER_FRAME + strike_bonus(shot_values, index)
      index += 1
    else
      frame_score = shot_values[index, 2].sum
      score += spare?(shot_values, index) ? (PINS_PER_FRAME + spare_bonus(shot_values, index)) : frame_score
      index += 2
    end
  end

  score
end

def strike?(value)
  value == PINS_PER_FRAME
end

def spare?(shot_values, index)
  shot_values.fetch(index, 0) + shot_values.fetch(index + 1, 0) == PINS_PER_FRAME
end

def strike_bonus(shot_values, index)
  shot_values.fetch(index + 1, 0) + shot_values.fetch(index + 2, 0)
end

def spare_bonus(shot_values, index)
  shot_values.fetch(index + 2, 0)
end

puts calculate_score(shot_values)
