require_relative './data/air_shell'

begin 
  AirShell::run
rescue Interrupt
  puts
rescue 
  puts "ERROR MH17: AirShell has crashed horribly. The blackbox was lost as well. There where no survivors."
end