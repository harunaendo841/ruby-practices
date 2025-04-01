#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

COUNT_ORDER = %i[lines words bytes]

options = { lines: false, words: false, bytes: false }
OptionParser.new do |opts|
  opts.on('-l') { options[:lines] = true }
  opts.on('-w') { options[:words] = true }
  opts.on('-c') { options[:bytes] = true }
end.parse!

options[:lines] = options[:words] = options[:bytes] = true if options.values.none?

def count_file_data(io)
  data = io.read
  {
    lines: data.count("\n"),
    words: data.split(/\s+/).count { |word| !word.empty? },
    bytes: data.bytesize
  }
end

def format_counts(counts, filename, options, padding)
  formatted = []
  COUNT_ORDER.each do |key|
    formatted << counts[key].to_s.rjust(padding) if options[key]
  end
  formatted << filename unless filename.empty?
  formatted.join(' ')
end

filenames = ARGV
all_counts = []
total = { lines: 0, words: 0, bytes: 0 }

if filenames.empty?
  counts = count_file_data($stdin)
  all_counts << counts
  filenames = ['']
  total = counts
else
  filenames.each do |filename|
    abort("Error: ファイル '#{filename}' が存在しません。") unless File.exist?(filename)
    abort("Error: '#{filename}' はファイルではありません。") unless File.file?(filename)

    File.open(filename) do |file|
      counts = count_file_data(file)
      COUNT_ORDER.each { |key| total[key] += counts[key] }
      all_counts << counts
    end
  end
end

padding = (all_counts + [total]).flat_map { |c| COUNT_ORDER.map { |key| c[key].to_s.length } }.max

filenames.each_with_index do |filename, i|
  puts format_counts(all_counts[i], filename, options, padding)
end

puts format_counts(total, 'total', options, padding) if filenames.size > 1
