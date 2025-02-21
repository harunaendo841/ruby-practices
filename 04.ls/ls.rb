#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMNS = (ENV['MAX_COLUMNS'] || 3).to_i
COLUMN_PADDING = (ENV['COLUMN_PADDING'] || 2).to_i

def validate_directory_path(path)
  abort("Error: 指定されたパス '#{path}' が存在しません！") unless Dir.exist?(path)
  abort("Error: 指定されたパス '#{path}' はディレクトリではありません！") unless File.directory?(path)
end

def generate_file_list(path)
  Dir.children(path).sort
end

def generate_file_table(file_list, columns)
  file_list.each_slice(columns).to_a
end

def calculate_column_widths(table)
  table.transpose.map { |col| col.compact.map(&:length).max || 0 }
end

def print_file_table(table, column_widths, padding)
  table.each do |row|
    formatted_row = row.map.with_index do |file, col|
      file ? file.ljust(column_widths[col] + padding) : ''
    end
    puts formatted_row.join
  end
end

def main
  directory_path = ARGV[0] || '.'
  validate_directory_path(directory_path)

  file_list = generate_file_list(directory_path)
  table = generate_file_table(file_list, MAX_COLUMNS)
  column_widths = calculate_column_widths(table)
  print_file_table(table, column_widths, COLUMN_PADDING)
end

main
