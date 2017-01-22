#require 'YAML' #only required if serializing in YAML

class Hangman

	def initialize
		@guesses = []
		@turn = 0
		@word = []
	end

	def menu
		puts "Please choose an option...
		1. Continue current game
		2. Save current game
		3. Play a new game
		4. Load a game
		5. Exit"
		
		option = gets.chomp
		case option
		when '1'
			if @turn == 0
				puts "You're not currently playing a game!"
				menu
			else
			play
			end
		when '2'
			if @turn == 0
				puts "You haven't started a game!"
				menu
			else
			save_game
		when '3'
			new_game
		when '4'
			load_game
		when '5'
			puts "Thanks for playing. Bye!"
			exit
		end
	end

	def play
		puts "To go to the menu type 'menu'."
		puts "To play guess a letter or an entire word..."
		if @guesses.any? #checks for previous guesses and lists them if there are any.
			puts "Your incorrect guesses so far are: #{@guesses.join(", ")}"
		end
		puts "#{@guessed_word.join(" ")}"
		guess = gets.chomp.downcase
		menu if guess == "menu" #takes player to the menu when they type menu
		if guess.length == 1 #checks for single letters
			@guesses << guess #adds single letter guesses to the guesses array
			letter_match(guess)
		else
			end_game?(guess) #checks for full word guesses and if any remaining turns
		end
		@turn += 1
		puts @guessed_word.join(" ") #shows correct guesses in word so far
		puts "You have #{12-@turn} guesses left"
		end_game?
		play
	end

	def new_game 
		initialize #resets all variables to start a game.
		pick_word
		@guessed_word = Array.new(@word.length, "_") #creates an array of underscores to show how many letters are missing
		play
	end

	def pick_word #opens dictionary text file and adds each word (line) between 5 and 12 letters to the dictionary array.
		dictionary = []
		File.open('5desk.txt').readlines.each do |line|
			dictionary << line.downcase if line.strip.length.between?(5,12)
		end
		@word = dictionary.sample.strip.split("") #picks random element on dictionary array (word) and splits it into an array of letters.
	end

	def letter_match(guess) #iterates the the word array and adds letters which match the guess to the guessed_word array leaving unmatched letters as underscores.
		@word.each_with_index do |letter, i|
			if guess == letter
				@guessed_word[i] = letter 
				@guesses.delete(guess) #removes correct guesses from the guesses array
			end
		end		
	end

	def end_game?(word_guess=nil) #checks if word matches guesses and if whole word guesses match word.
		if @guessed_word == @word || word_guess == @word.join
			puts "You win! You correctly guessed the word was #{@word.join}"
			exit
		elsif @turn == 12 #checks number of turns remaining
			puts "You lose! The word was #{@word.join}"
			exit
		end
	end

	def display_saves #lists files in 'saves' folder
		puts "Saved games:"
		Dir.glob("saves/*").each do |file|
			puts file
		end
	end
#serialization with Marshal
	def save_game
		Dir.mkdir("saves") unless Dir.exists? "saves"
		display_saves
		puts "Enter game name"
		name = gets.chomp
		File.open("saves/#{name}",'w') do |f|
			Marshal.dump(self, f)
		end
		puts "save successful"
	end

	def load_game
		display_saves
		puts "Enter game name"
		name = gets.chomp
		File.open("saves/#{name}",'r') do |f|
			@loaded_game = Marshal.load(f)
		end
			@loaded_game.play
	end
	
=begin #serialization with YAML rather than Marshal - much simpler, but means user can edit game files manually!
		def save_game
		Dir.mkdir("saves") unless Dir.exists? "saves"
		display_saves
		puts "Enter game name"
		name = gets.chomp
		File.open("saves/#{name}",'w').puts YAML.dump(self)
		puts "save successful"
	end

	def load_game
		display_saves
		puts "Enter game name"
		name = gets.chomp
		loaded_game = YAML.load(File.open("saves/#{name}",'r'))
		loaded_game.play
	end
=end
end

Hangman.new.menu