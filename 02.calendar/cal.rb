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
  print_week_rows(cells)
end

def generate_cells(first_day, last_day)
  Array.new(first_day.wday, '  ') + (1..last_day.day).map { |day| day.to_s.rjust(2) }
end

def print_week_rows(cells)
  cells.each_slice(7) { |week| puts week.join(' ') }
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

  abort 'Error: Month must be between 1 and 12.' unless (1..12).cover?(options[:month])

  options
end

options = parse_options
print_calendar(options[:year], options[:month])
