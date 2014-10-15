require 'shell'

class Shell::Filter

  # call-seq:
  #   >> source
  #
  # Appends the output to +source+, which is either a string of a file name
  # or an IO object.
  def >> (to)
    begin
      Shell.cd(@shell.pwd).append(to, self)
    rescue Error::CantApplyMethod
      Shell.Fail Error::CantApplyMethod, '>>', to.class
    end
  end

end

class Shell::AppendToIO
  def initialize(sh, io, filter)
    super sh
    self.input = filter
    @io = io
  end

  def input=(filter)
    @input = filter
    @input.each { |l| @io << l }
  end
end

# Pretty fly for a ruby... thing
class PilotShell

  def initialize
    @sh = Shell.new
  end

  def eval(command)
    sh.system(command)
  end

end