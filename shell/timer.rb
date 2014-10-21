require 'optparse'
# require_relative './data/timer/timer'
options = {}
OptionParser.new do |opts|
	opts.banner = "Usage: timer.rb [options]"

	opts.on("-b", "--blocking") do
		options[:block] = true
	end
end.parse!
if options[:block]
	Timer::timer(ARGV[1], ARGV[2])
else
	Timer::start(ARGV[1], ARGV[2])
end
