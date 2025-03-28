#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

options = { lines: false, words: false, bytes: false }
OptionParser.new do |opts|
  opts.on('-l') { options[:lines] = true }
  opts.on('-w') { options[:words] = true }
  opts.on('-c') { options[:bytes] = true }
end.parse!

options[:lines] = options[:words] = options[:bytes] = true if options.values.none?

def count_file_data(io)
  data = io.read
  lines = data.count("\n")
  words = data.split(/\s+/).count { |word| !word.empty? }
  bytes = data.bytesize
  [lines, words, bytes]
end

def format_counts(counts, filename, options, padding)
  formatted = []
  formatted << counts[0].to_s.rjust(padding) if options[:lines]
  formatted << counts[1].to_s.rjust(padding) if options[:words]
  formatted << counts[2].to_s.rjust(padding) if options[:bytes]
  formatted << filename unless filename.empty?
  formatted.join(' ')
end

filenames = ARGV
all_counts = []
total = [0, 0, 0]

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
      total = total.zip(counts).map { |a, b| a + b }
      all_counts << counts
    end
  end
end

padding = (all_counts + [total]).flatten.map(&:to_s).map(&:length).max

filenames.each_with_index do |filename, i|
  puts format_counts(all_counts[i], filename, options, padding)
end

puts format_counts(total, 'total', options, padding) if filenames.size > 1
