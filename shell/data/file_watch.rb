require 'test/unit'
require_relative 'file_watch/watcher'

class FileWatch

  def initialize(mode, delay, *files, &block)
    assert block_given?
    pre_initialize(mode, delay, files)

    @watchers = files.map do |f|
      Watcher.new(mode, delay, f, &block)
    end

    @mode = mode
    @delay = delay
    @files = files
  end

  attr_reader :mode, :delay, :files

  def run
    watchers.each do |w|
      fork do
        begin
          w.run
        rescue SystemCallError
          "Watcher #{w} failed to start."
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
    assert self.class.valid_modes.include? mode.to_sym
    assert delay.respond_to? :to_int
    assert files.all? { |f| f.respond_to? :to_s }
  end

  attr_reader :watchers

end