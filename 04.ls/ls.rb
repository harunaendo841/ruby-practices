#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

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

def file_details(file_name, path, widths)
  stat = File.lstat(File.join(path, file_name))

  format(
    "%<mode>s %<nlink>#{widths[:nlink]}d %-<owner>-#{widths[:owner]}s %-<group>-#{widths[:group]}s %<size>#{widths[:size]}d %<mtime>s %<name>s",
    mode: format_mode(stat.mode),
    nlink: stat.nlink,
    owner: Etc.getpwuid(stat.uid).name,
    group: Etc.getgrgid(stat.gid).name,
    size: stat.size,
    mtime: stat.mtime.strftime('%b %d %H:%M'),
    name: file_name
  )
end

def calculate_field_widths(file_list, path)
  stats = file_list.map { |f| File.lstat(File.join(path, f)) }
  {
    nlink: stats.map(&:nlink).map(&:to_s).map(&:size).max,
    owner: stats.map { |s| Etc.getpwuid(s.uid).name.size }.max,
    group: stats.map { |s| Etc.getgrgid(s.gid).name.size }.max,
    size: stats.map { |s| s.size.to_s.size }.max
  }
end

def calculate_total_blocks(file_list, path)
  total_blocks = file_list.sum { |f| File.lstat(File.join(path, f)).blocks }
  total_blocks / 2
end

def format_mode(mode)
  type = case mode & 0o170000
         when 0o040000 then 'd'
         when 0o100000 then '-'
         when 0o120000 then 'l'
         when 0o020000 then 'c'
         when 0o060000 then 'b'
         when 0o140000 then 's'
         else '?'
         end

  perms = (0..8).map { |i| (mode & (1 << (8 - i))).zero? ? '-' : 'rwxrwxrwx'[i] }.join

  type + perms
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
  options = { show_all: false, reverse: false, detailed_view: false }
  OptionParser.new do |opts|
    opts.on('-a', '隠しファイルを表示') { options[:show_all] = true }
    opts.on('-r', 'ファイルを逆順で表示') { options[:reverse] = true }
    opts.on('-l', '詳細情報を表示') { options[:detailed_view] = true }
  end.parse!

  path = ARGV.first || '.'
  validate_directory_path(path)

  file_list = generate_file_list(path, options[:show_all], options[:reverse])

  if options[:detailed_view]
    puts "total #{calculate_total_blocks(file_list, path)}"
    widths = calculate_field_widths(file_list, path)
    puts(file_list.map { |file| file_details(file, path, widths) })
  else
    file_table = format_file_table(file_list, MAX_COLUMNS)
    column_widths = calculate_column_widths(file_table)
    print_file_table(file_table, column_widths, COLUMN_PADDING)
  end
end

main
