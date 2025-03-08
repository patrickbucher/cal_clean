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
lines_by_path = content_by_path.map { |p, c| [p, c.lines.map(&:strip)] }.to_h

puts(lines_by_path)

# TODO
# - for each file, cut out sections from BEGIN:VEVENT until END:VEVENT
# - parse DTSART:[DATE] and DTSTART;TDZID=[TZ:DATE]
# - get the earliest (i.e. minimal) date for each file
# - delete (or list for dry run) each file