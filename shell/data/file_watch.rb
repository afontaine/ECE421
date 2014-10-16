class FileWatch

  def initialize(mode, delay, *files)
    @mode = mode
    @delay = delay
    @files = files
  end

  attr_reader :mode, :delay, :files

end