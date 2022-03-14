require 'byebug'
require 'mechanize'
require 'awesome_print'
require 'tty-prompt'
require "./lib/attempt"
require "./lib/menu_attempt"

if $0 == __FILE__
	mechanize = Mechanize.new
	prompt = TTY::Prompt.new

	attempt = Attempt.new(mechanize:Mechanize.new, prompt: TTY::Prompt.new)
	attempt.connect
	connected = true
	menu = MenuAttempt.new(res: attempt, username: attempt.username)

	eval("menu.help");
	# while connected
	# 	print "[#{attempt.username}]> "
	# 	choice = gets.chomp
	# 	eval("menu.#{choice}");
	# end
end
