require 'test/unit'

class FileWatch
  class Watcher
    include Test::Unit::Assertions

    @@valid_modes = [:create, :update, :delete]

    def initialize(mode, delay, file, &block)
      pre_initialize(mode, delay, file)
      assert block_given?

      @mode = mode.to_sym
      @delay = delay.to_int
      @file = file.to_s
      @block = block
    end

    def run
      assert self.class.valid_modes.include? mode
      @running = true
      case mode
        when :create
          assert !File.exist?(file), "Expected #{file} to not exist"
          spin_wait { !File.exist?(file) }
        when :update
          assert File.exist?(file), "Expected #{file} to exist"
          current_time = File.mtime(file)
          spin_wait { current_time == File.mtime(file) }
        when :delete
          assert File.exist?(file), "Expected #{file} to exist"
          spin_wait { File.exist?(file) }
        else
          raise "#{mode} not a valid mode"
      end
    end

    def stop
      @running = false
    end

    attr_reader :mode, :delay, :file, :block

    private
    def self.valid_modes
      return @@valid_modes
    end

    def pre_initialize(mode, delay, file)
      assert mode.respond_to? :to_sym
      assert self.class.valid_modes.include? mode.to_sym
      assert delay.respond_to? :to_int
      assert file.respond_to? :to_s
    end

    def spin_wait
      sleep(0) while yield && @running
      return unless @running
      exec_changes
    end

    def exec_changes
      sleep(delay / 1000.0)
      block.call(file)
    end
  end
end