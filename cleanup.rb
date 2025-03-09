#!/usr/bin/env ruby

require "date"

def extract_sub_sequences(seq, start_with, end_with)
  sub_sequences = []
  sub_sequence = []
  within = false
  seq.each do |entry|
    if entry == start_with
      if within
        raise "nested sub-sequences"
      else
        within = true
      end
    elsif entry == end_with
      if !within
        raise "closing unopened sub-sequence"
      else
        sub_sequences << sub_sequence
        sub_sequence = []
        within = false
      end
    elsif within
      sub_sequence << entry
    end
  end
  sub_sequences
end

def parse_file(path)
  f = File.new(path)
  return nil unless File.file?(f)

  content = f.read()
  lines = content.lines.map(&:strip)
  events = extract_sub_sequences(lines, "BEGIN:VEVENT", "END:VEVENT")
  { path: path, events: events }
end

def extract_start_date(lines)
  start_date_lines = lines.filter { |l| l.start_with?("DTSTART") }
  raise "ambiguous start date" if start_date_lines.count != 1

  start_date_line = start_date_lines.first
  parts = start_date_line.split(":")
  raise "multiple : on line #{start_date_line}" if parts.count != 2

  DateTime.parse(parts[1]).to_date
end

folder = ARGV[0]
cutoff_date = Date.parse(ARGV[1])
if cutoff_date.nil?
  exit(1)
end
delete_until_datetime = Date.new(cutoff_date.year, cutoff_date.month, cutoff_date.day)

entries = Dir.entries(folder)
paths = entries.map { |e| File.join(folder, e) }
events_by_path =
  paths
    .map { |p| parse_file(p) }
    .filter { |e| e }
    .reduce({}) { |acc, e| acc.update({ e[:path] => e[:events] }) }
start_dates_by_path =
  events_by_path
    .filter { |_, v| !v.empty? }
    .map { |k, v| [k, v.map { |e| extract_start_date(e) }.min] }.to_h
to_be_deleted = start_dates_by_path.filter { |k, v| v < cutoff_date }

to_be_deleted.each do |k, v|
  # TODO: actually delete files after gaining enough confidence
  puts("delete #{k} from #{v.strftime("%Y-%m-%d")}")
end
