#!/usr/bin/env ruby
require 'optparse'
require "date"


# コマンドラインからオプション引数を受け取る
opt = OptionParser.new
today = Date.today

year = 0
month = 0

opt.on('-y month') {|v| year = v.to_i  }
opt.on('-m month') {|v| month = v.to_i }

opt.parse(ARGV)


# 年、月、日、月初日、月末日、月初曜日を用意
year = today.year if year == 0
month = today.mon if month == 0
firstday = 1
lastday = Date.new(year,month, -1).day
date = Date.parse("#{year}/#{month}/#{firstday}")
doy = date.wday


## 年月を表示
puts "#{month}月 #{year}".center(20)

## 曜日一覧を表示
doys = ["日 ", "月 ", "火 ", "水 ", "木 ","金 " ,"土\n"]
doys.each do |d|
  print d
end

## カレンダーの初日から最終日までの配列を作成
cal = (firstday..lastday).to_a

## 月初の曜日に合わせて空白を追加(繰り返しのためにcal.eachやtimesで書いてみたけどしっくりこなかった)
# 7.times do |i|
#    if (doy + cal[6]) % 7 != 0
#      cal.insert(0," ")
#    else
#     next
#    end
# end

## 月初の曜日に合わせて空白を追加
while (doy + cal[6]) % 7 != 0
  cal.insert(0," ")
end

## 繰り返し回数を取得するための変数n
n = 0

## 配列を出力
cal.each do |i|
  n += 1
  ## 1桁の場合は両側に空白を表示して見た目を揃える
  if i.to_i < 10
    print " #{i} "
  else
  ## 2桁の場合は右側に空白を出力して見た目を揃える
    print "#{i} "
  end
## 7桁表示した後改行
  print ("\n") if (n % 7) == 0
## 最後の日付を表示後に改行して空白行を挿入
  puts ("\n ") if i == cal.last
end
