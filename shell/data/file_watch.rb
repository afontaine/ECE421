require 'test/unit'
require_relative 'file_watch/watcher'

class FileWatch
  include Test::Unit::Assertions

  def initialize(mode, delay, *files, &block)
    assert block_given?
    pre_initialize(mode, delay, files)

    @mode = mode.to_sym
    @delay = delay.to_int
    @files = files.map { |f| f.to_s }
    @threads = []

    @watchers = @files.map do |f|
      Watcher.new(@mode, @delay, f, &block)
    end
  end

  attr_reader :mode, :delay, :files, :threads

  def run(out = $stdout)
    watchers.each do |w|
      threads << Thread.new do
        $stdout = out
        begin
          w.run
        rescue SystemCallError
          puts "Error running file watch on #{w.file}"
          return -1
        end
      end
    end
  end

  def stop
    watchers.each { |w| w.stop }
  end

  private
  def pre_initialize(mode, delay, files)
    assert mode.respond_to? :to_sym
    assert Watcher.valid_modes.include? mode.to_sym
    assert delay.respond_to? :to_int
    assert files.respond_to? :all?
    assert files.all? { |f| f.respond_to? :to_s }
  end

  attr_reader :watchers

end