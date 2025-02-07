#!/usr/bin/env ruby
# frozen_string_literal: true

require 'date'
require 'optparse'

def print_calendar(year, month)
  first_day = Date.new(year, month, 1)
  last_day  = Date.new(year, month, -1)

  header = "#{Date::MONTHNAMES[month]} #{year}".center(20)
  puts header
  puts 'Su Mo Tu We Th Fr Sa'

  cells = generate_cells(first_day, last_day)
  print_week_rows(cells, first_day, last_day)
end

def generate_cells(first_day, last_day)
  cells = Array.new(42, '  ')
  offset = first_day.wday
  (1..last_day.day).each do |day|
    cells[offset] = day.to_s.rjust(2)
    offset += 1
  end
  cells
end

def print_week_rows(cells, first_day, last_day)
  last_index = first_day.wday + last_day.day - 1
  week_count = (last_index / 7) + 1
  week_count.times do |week|
    start_index = week * 7
    row = if week == week_count - 1 && last_index % 7 != 6
            cells[start_index, last_index % 7 + 1]
          else
            cells[start_index, 7]
          end
    puts row.join(' ')
  end
end

def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: ./cal.rb [-y YEAR] [-m MONTH]'
    opts.on('-m MONTH', Integer, 'Specify month (1..12)') { |m| options[:month] = m }
    opts.on('-y YEAR',  Integer, 'Specify year') { |y| options[:year] = y }
  end.parse!

  options[:year]  ||= Date.today.year
  options[:month] ||= Date.today.month

  unless (1..12).cover?(options[:month])
    puts 'Error: Month must be between 1 and 12.'
    exit 1
  end

  options
end

options = parse_options
print_calendar(options[:year], options[:month])
