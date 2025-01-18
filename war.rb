require 'irb'

class Card
    RANKS = %w(2 3 4 5 6 7 8 9 10 J Q K A)
    SUITS = %w(♠ ♥ ♣ ♦)
    # https://en.wikipedia.org/wiki/Playing_cards_in_Unicode

    attr_accessor :rank, :suit

    def initialize(id)
        self.rank = RANKS[id % 13]
        self.suit = SUITS[id % 4]
    end

    def to_s
        "#{self.rank} #{self.suit.encode('UTF-8')}"
    end
end

class Deck
    attr_accessor :cards
    def initialize
        #shuffle and initialize cards
        self.cards = (0..51).to_a.shuffle.collect {|id| Card.new(id)}
    end
end

class Player
    attr_accessor :name
    attr_accessor :hand

    def initialize(name)
        self.name = name
        self.hand = []
    end

    def to_s
        self.name
    end
end

def deal(deck, p1, p2)
    # we could just assign half the deck array to each player BUT...
    # the way I would play "war" is dealing cards
    # until all cards are dealt
    switch = true
    deck.cards.each do |card|
        switch ? p1.hand << card : p2.hand << card
        switch ? switch = false : switch = true
    end 
end

def process_war(winnings=[])
    @wars += 1
    #puts "WAR!"    
    #puts ("both players play 3 cards face down + 1 face up")
    if @p1.hand.size < 4
        @winner = @p2
        #puts ("p2 is winner, p1 didn't have enough cards left to WAR")
        ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @elapsed = ending - @game_started
    
        #puts "Game Over - #{@winner} Wins!"
        #puts "#{@turns} turns played in #{@elapsed} seconds. There were #{@wars} wars!"
        @win_condition = true
        return false
    elsif @p2.hand.size < 4
        @winner = @p1
        #puts ("p1 is winner, p2 didn't have enough cards left to WAR")
        ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        @elapsed = ending - @game_started
    
        #puts "Game Over - #{@winner} Wins!"
        #puts "#{@turns} turns played in #{@elapsed} seconds. There were #{@wars} wars!"
        @win_condition = true
        return false
    end

    winnings << [@p1.hand.shift, @p1.hand.shift, @p1.hand.shift]
    winnings << [@p2.hand.shift, @p2.hand.shift, @p2.hand.shift]
    current_cards = [@p1.hand.shift, @p2.hand.shift]

    turn_result = process_turn(current_cards)
    if turn_result == :war
        @sub_wars += 1
        #puts "WAR RESULT: ANOTHER WAR! # #{@sub_wars}\n\n"
        #sleep(5)
        process_war(winnings)
    elsif turn_result == :p1_win
        winnings << current_cards
        winnings.flatten.shuffle.each {|c| @p1.hand << c}
        #puts "WAR RESULT: [#{@p1.hand.size}:#{@p2.hand.size}] \n#{@p1}: #{current_cards[0]}   vs   #{@p2}: #{current_cards[1]}\n\n"
        #puts "#{@p1} won hand (#{winnings.flatten.size} cards won!)\n"
        @sub_wars = 1
    elsif turn_result == :p2_win
        winnings << current_cards
        winnings.flatten.shuffle.each {|c| @p2.hand << c}
        #puts "WAR RESULT: [#{@p1.hand.size}:#{@p2.hand.size}] \n#{@p1}: #{current_cards[0]}   vs   #{@p2}: #{current_cards[1]}\n\n"
        #puts "#{@p2} won hand (#{winnings.flatten.size} cards won!)\n"
        @sub_wars = 1
    end

end

def process_turn(cards)
    # cards Array with Card instances
    # index 0: player 1's card
    # imdex 1: player 2's card
    if cards[0].rank == cards[1].rank
        :war
    else
        card_ranks = [cards[0].rank, cards[1].rank]
        winning_card = card_ranks.max

        if card_ranks.index(winning_card) == 0
            :p1_win
        else
            :p2_win
        end
    end
end

def play_game(simulate=false)
    @deck = Deck.new
    @p1 = Player.new('Ryan')
    @p2 = Player.new('Austin')

    deal(@deck, @p1, @p2)

    @win_condition = false
    @winnings = []
    @turns = 0
    @wars = 0
    @sub_wars = 1
    @game_started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    while !@win_condition do
        @turns += 1
        # each player "plays" their next card
        cards = [@p1.hand.shift, @p2.hand.shift]
        #puts "[t: #{@turns}] [#{@p1.hand.size}:#{@p2.hand.size}] \n#{@p1}: #{cards[0]}   vs   #{@p2}: #{cards[1]}\n\n"
        turn_result = process_turn(cards)
        
        if turn_result == :war
            process_war()
        elsif turn_result == :p1_win
            @winnings << cards
            #puts "#{@p1} won hand (#{@winnings.flatten.size} cards won!)\n"
            # if winnings aren't shuffled here
            # game goes into never ending draw/repeated pattern where score stays even infinitely
            @winnings.flatten.shuffle.each {|c| @p1.hand << c}
            @winnings = []
        elsif turn_result == :p2_win
            @winnings << cards
            #puts "#{@p2} won hand (#{@winnings.flatten.size} cards won!)\n"
            # if winnings aren't shuffled here
            # game goes into never ending draw/repeated pattern where score stays even infinitely
            @winnings.flatten.shuffle.each {|c| @p2.hand << c}
            @winnings = []
        end
    
        if @p1.hand.size == 0 or @p2.hand.size == 0
            if @p1.hand.size > @p2.hand.size
                @winner = @p1
            else
                @winner = @p2
            end

            ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
            @elapsed = ending - @game_started
        
            #puts "Game Over - #{@winner} Wins!"
            #puts "#{@turns} turns played in #{@elapsed} seconds. There were #{@wars} wars!"
            # if simulate
            #     [@turns, @elapsed, @wars, @sub_wars]
            # end            

            @win_condition = true
        end

    end
    if simulate
        return [@turns, @elapsed, @wars, @sub_wars]
    end
end


def simulate(num_games)
    turns = []
    elapsed = []
    avg_wars = []
    @avg_sub_wars = [] 
    num_games.times do |n|
        result = play_game(true)
        turns << result[0]
        elapsed << result[1]
        avg_wars << result[2]
        @avg_sub_wars << result[3]
    end

    turns_average = turns.sum(0.0) / turns.size
    elapsed_average = elapsed.sum(0.0) / elapsed.size

    wars_average = avg_wars.sum(0.0) / avg_wars.size
    subwars_average = @avg_sub_wars.sum(0.0) / @avg_sub_wars.size


    puts "\n\n--------\n#{num_games} games simulated"
    puts "avg turns: #{turns_average.round}"
    puts "avg CPU time elapsed: #{elapsed_average.round} sec"

    if num_games > 1
        puts "avg number of total wars #{wars_average.round}"
        puts "avg number of sub wars #{subwars_average.round}"
    end

    # real time: (assume 1 second for players IRL to see outcome and play next round)
    realtime = (elapsed_average + (turns_average * 1.5).to_f).round
    puts "avg (estimated real) time elapsed: #{realtime} sec  (#{realtime / 60} min)"

    double_wars = 0
    triple_wars = 0
    quad_wars = 0
    quint_wars = 0

    for stat in @avg_sub_wars
        if stat == 2
            double_wars += 1
        end
        if stat == 3
            triple_wars += 1
        end
        if stat == 4
            quad_wars += 1
        end
        if stat == 5
            quint_wars += 1   
        end
    end
    print("number of double_wars wars: #{double_wars}\n\n")
    print("number of triple_wars: #{triple_wars}\n\n")
    print("number of quad_wars #{quad_wars}\n\n")
    print("number of quint_wars #{quint_wars}\n\n")

    print("is it possible to have 5x wars in a row with the number of cars. Yes, with this ruleset, that is the max?")
end
