require_relative 'data/file_watch'
# Run a 5 second timer and print "Hello" to the console
`ruby timer.rb 5 "hello"`

# Supports a switch to block if you want
`ruby timer.rb --block 5 "hello"`

# Watch for a modified file
# command line also available: ruby file_watch.rb --help
f = FileWatch.new(:modify, 'Gemfile') { |e| puts "hello" }
f.run_async
wait 5
# Stops the watcher
f.stop

# Starts the shell session
`ruby shell.rb`