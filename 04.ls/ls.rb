#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

MAX_COLUMNS = 3
COLUMN_PADDING = 2

def validate_directory_path(path)
  abort("Error: 指定されたパス '#{path}' が存在しません。") unless File.exist?(path)
  abort("Error: 指定されたパス '#{path}' はディレクトリではありません。") unless File.directory?(path)
end

def generate_file_list(path, show_all, reverse)
  files = Dir.entries(path)
  files.reject! { |f| f.start_with?('.') } unless show_all
  files.sort!
  files.reverse! if reverse
  files
end

def format_file_table(file_list, columns)
  rows = (file_list.size.to_f / columns).ceil
  table = Array.new(rows) { Array.new(columns) }

  file_list.each_with_index do |file, index|
    col = index / rows
    row = index % rows
    table[row][col] = file
  end

  table
end

def calculate_column_widths(table)
  table.transpose.map do |col|
    col.compact.map(&:length).max || 0
  end
end

def print_file_table(table, column_widths, padding)
  table.each do |row|
    row.each_with_index do |file, col|
      print file.ljust(column_widths[col] + padding) if file
    end
    puts
  end
end

def main
  options = { show_all: false, reverse: false }
  OptionParser.new do |opts|
    opts.on('-a', '隠しファイルを表示') { options[:show_all] = true }
    opts.on('-r', 'ファイルを逆順で表示') { options[:reverse] = true }
  end.parse!

  path = ARGV.first || '.'

  validate_directory_path(path)

  file_list = generate_file_list(path, options[:show_all], options[:reverse])
  file_table = format_file_table(file_list, MAX_COLUMNS)
  column_widths = calculate_column_widths(file_table)
  print_file_table(file_table, column_widths, COLUMN_PADDING)
end

main
