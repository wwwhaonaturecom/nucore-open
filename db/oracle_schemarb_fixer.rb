#!/usr/bin/env ruby

schema_path=ARGV[0]

if schema_path.nil?
  puts "Usage: ./oracle_schemarb_fixer.rb <path to schema.rb>"
  exit 1
end

schema_file=File.open(schema_path, 'r')
schema_lines=schema_file.readlines
schema_file.close

fks=[]
schema=[]

schema_lines.each do |line|
  if line.include? 'add_foreign_key'
    fks << line
  else
    schema << line
  end
end

the_end=schema.pop
schema += fks.uniq
schema.push the_end

File.open("#{schema_path}.new", 'w') do |f|
  schema.each {|line| f << line }
end




