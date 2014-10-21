require 'getoptlong'
require_relative 'data/file_watch'

def is_num?(str)
  begin
    !!Integer(str)
  rescue ArgumentError, TypeError
    false
  end
end

opts = GetoptLong.new(
    ['--help', '-h', GetoptLong::NO_ARGUMENT],
    ['--files', '-f', GetoptLong::REQUIRED_ARGUMENT],
    ['--mode', '-m', GetoptLong::REQUIRED_ARGUMENT],
    ['--delay', '-d', GetoptLong::OPTIONAL_ARGUMENT],
    ['--cmd', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

files, command, mode, delay = nil, nil, nil, nil

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
file_watch -f "files to watch" -m mode -d delay -c "shell command to run with"

-h, --help:
  show help

--f file list, --files file list:
  List of files to watch

-m mode, -mode mode:
  Mode to use. Valid values are create, update, or delete

-d delay, --delay delay:
  Time delay in milliseconds to use. Default 100

-c command --cmd command:
  Shell command to run upon trigger of mode
  All occurrences of %FILE_NAME% are replaced with the file name

EOF
      exit(0)
    when '--files'
      abort('Non empty list of files must be provided') if arg == ''
      files = arg.split(/\s(?=(?:[^"]|"[^"]*")*$)/)
    when '--mode'
      abort('Non empty mode of create, update, or delete must be provided') unless FileWatch::Watcher.valid_modes.include? arg.to_sym
      mode = arg.to_sym
    when '--delay'
      delay = is_num?(arg) ? 100 : arg.to_i
    when '--cmd'
      abort('Non empty action must be provided') if arg == ''
      command = arg
    else
      abort("unknown option #{opt} provided")
  end
end

abort('Missing arguments, see --help for usage') if files.nil? || command.nil? || mode.nil?

begin
  watch = FileWatch.new(mode, delay, *files) { |f| puts `#{command.gsub('%FILE_NAME%', f)}` }
  watch.run
rescue Interrupt
  abort('FileWatch terminated by user')
rescue StandardError
  abort('Error running FileWatch')
end