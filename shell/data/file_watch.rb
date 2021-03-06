require 'test/unit'
require 'thwait'
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

  attr_reader :mode, :delay, :files

  def run
    @watchers.each do |w|
      @threads << Thread.new do
        begin
          w.run
        rescue SystemCallError
          puts "SystemCallError running file watch on #{w.file}"
        rescue Test::Unit::AssertionFailedError => e
          puts "Error: #{e.message.lines.first}"
        end
      end
    end

    ThreadsWait.all_waits(*@threads)
    @threads = []
  end

  def run_async
    Thread.new { run }
  end

  def stop
    @watchers.each { |w| w.stop }
  end

  private
  def pre_initialize(mode, delay, files)
    assert mode.respond_to? :to_sym
    assert Watcher.valid_modes.include? mode.to_sym
    assert delay.respond_to? :to_int
    assert files.respond_to? :all?
    assert files.all? { |f| f.respond_to? :to_s }
  end

end