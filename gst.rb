#!/usr/bin/env ruby
require "rubygems"
require "money"

total    = ARGV.first.to_money
pst      = total - (total / 1.075)
gst      = (total - pst) - ((total - pst) / 1.05)
subtotal = (total - pst - gst)

cgst     = subtotal * 0.05
cpst     = (subtotal + cgst) * 0.075
ctotal   = subtotal + cgst + cpst

fgst    = total * 0.05
fpst    = (total + fgst) *0.075
ftotal  = total + fgst + fpst

puts "Subtotal:\t#{subtotal}\t\t\t#{total}"
puts "GST:\t\t#{gst}\t#{cgst}\t#{cgst * 0.5}\t#{fgst}"
puts "PST:\t\t#{pst}\t#{cpst}\t#{cpst * 0.5}\t#{fpst}"
puts "Total:\t\t#{total}\t#{ctotal}\t#{subtotal + (cgst * 0.5) + (cpst * 0.5)}\t#{ftotal}"
