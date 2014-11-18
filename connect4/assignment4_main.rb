require 'gtk2'
require_relative 'src/controllers'
require_relative 'src/models'

path = File.dirname(__FILE__)
builder = Gtk::Builder.new
builder.add_from_file(File.join(path, 'src/views/game_view.glade'))
board = Models::Board.new(6, 7)
player = Models::Player.new({X: 21}, [:X] * 4)
opponent = Models::AIPlayer.new({O: 21}, [:O] * 4)
controller = Controllers::GameController.new(board, 'Connect 4', player, opponent, builder, Models::Skin.default)
builder['game_window'].show
builder.connect_signals { |h| controller.method(h) }
Gtk.main