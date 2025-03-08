#!/usr/bin/env ruby

require "date"

folder = ARGV[0]
date = Date.parse(ARGV[1])
if date.nil?
  exit
end
delete_until_datetime = Time.new(date.year, date.month, date.day, 23, 59, 59)

entries = Dir.entries(folder)
paths = entries.map { |e| File.join(folder, e) }
files_by_path = paths.map { |p| [p, File.new(p)] }.to_h
files_by_path = files_by_path.filter { |p, f| File.file?(f) }
content_by_path = files_by_path.map { |p, f| [p, f.read()] }.to_h