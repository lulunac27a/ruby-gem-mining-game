# gem_mining.rb

class GemMiningGame
  # Define gem tiers with their base values and dynamic luck weight multipliers
  # High weight modifier means that upgrade levels dramatically boost this gem's spawn rate
  GEM_TYPES = {#gem tiers with base values and weight modifiers
    "Coal"       => { base_value: 1,    weight_modifier: 0.0 },
    "Quartz"     => { base_value: 5,    weight_modifier: 0.2 },
    "Iron Ore"   => { base_value: 20,   weight_modifier: 0.5 },
    "Gold Ore"   => { base_value: 100,  weight_modifier: 1.0 },
    "Emerald"    => { base_value: 500,  weight_modifier: 1.8 },
    "Ruby"       => { base_value: 2500, weight_modifier: 2.8 },
    "Diamond"    => { base_value: 12500,weight_modifier: 4.0 },
    "Obsidian"   => { base_value: 75000,weight_modifier: 5.5 }
  }

  def initialize#initialize game state
    @wallet = 0#current player wallet
    @upgrade_level = 1#current upgrade level of the mining gear
    @total_mined = 0#total number of ores mined
  end

  # Calculate upgrade cost using an exponential scaling formula (infinite upgrades)
  def upgrade_cost#cost to upgrade mining gear based on current level
    (50 * (1.55 ** (@upgrade_level - 1))).round
  end

  # Generates dynamic roll chances based on the current upgrade level
  def calculate_spawn_chances#calculate the spawn chances for each gem type based on upgrade level and base values
    weights = {}#weights hash to store calculated weights for each gem type
    
    GEM_TYPES.each do |name, properties|#repeat for each gem type
      # Base probability curve that naturally decays for rare gems
      base_probability = 100.0 / (properties[:base_value] ** 0.4)
      
      # Upgrades scale up the probability of rarer gems via their weight modifiers
      upgrade_bonus = 1.0 + ((@upgrade_level - 1) * properties[:weight_modifier] * 0.15)
      
      weights[name] = base_probability * upgrade_bonus#calculate the final weight for this gem type
    end

    # Normalize weights into percentage probabilities for display
    total_weight = weights.values.sum#calculate the total weight of all gem types
    probabilities = {}
    weights.each { |name, weight| probabilities[name] = ((weight / total_weight) * 100).round(2) }#convert weights to percentage probabilities
    probabilities
  end

  # Simulates mining a single ore using a weighted random sample
  def mine_ore#simulate the mining process and determine which gem is found based on weighted probabilities
    chances = calculate_spawn_chances#calculate the current spawn chances for each gem type
    roll = rand(0.0..100.0)#generate a random roll between 0 and 100 to determine which gem is found
    cumulative = 0.0

    chances.each do |gem_name, percentage|#iterate through each gem type and its corresponding spawn chance
      cumulative += percentage
      if roll <= cumulative#if the random roll falls within the cumulative chance for this gem type, it is selected
        value = GEM_TYPES[gem_name][:base_value]
        # Upgrades also grant a flat multiplier bonus to all income
        final_value = (value * (1 + (@upgrade_level - 1) * 0.1)).round#calculate the final value of the mined gem after applying the upgrade multiplier
        
        @wallet += final_value#add the final value of the mined gem to the player's wallet
        @total_mined += 1#increment the total mined count
        
        puts "\n⛏️  [MINE] You swung your pickaxe and unearthed: #{gem_name}!"
        puts "   Base value: $#{value} -> Level Multiplier applied! Earned: $#{final_value}"
        return
      end
    end
  end

  # Purchases a tool upgrade if funds are sufficient
  def buy_upgrade#attempt to purchase an upgrade for the mining gear if the player has enough funds
    cost = upgrade_cost
    if @wallet >= cost#check if the player has enough funds to purchase the upgrade
      @wallet -= cost
      @upgrade_level += 1#increment the upgrade level of the mining gear
      puts "\n✨ [UPGRADE] Success! Your mining gear is now Level #{@upgrade_level}!"
      puts "   Rare gem spawn rates and overall income multiplier have increased."
    else#if the player does not have enough funds, display an error message
      puts "\n❌ [ERROR] Insufficient funds! You need $#{cost} (Current: $#{@wallet})."
    end
  end

  # Main interactive game loop
  def play#start the main game loop, displaying options and handling user input
    puts "================================================="
    puts "💎 WELCOME TO ENDLESS GEM MINER 💎"
    puts "================================================="
    
    loop do#display the main menu and handle user input in a loop
      puts "\n-------------------------------------------------"
      puts " Wallet: $#{@wallet} | Gear Level: #{@upgrade_level} | Total Mined: #{@total_mined}"
      puts "-------------------------------------------------"
      puts " [1] Mine Ore"
      puts " [2] Upgrade Gear (Cost: $#{upgrade_cost})"
      puts " [3] Check Current Drop Chances"
      puts " [4] Exit Game"
      print " Choose an action: "
      
      choice = gets.chomp.to_s#get user input for the action they want to take

      case choice
      when "1"
        mine_ore#simulate mining an ore and display the result
      when "2"
        buy_upgrade#attempt to purchase an upgrade for the mining gear
      when "3"
        puts "\n--- Current Dynamic Drop Rates ---"#display the current drop rates for each gem type based on the player's upgrade level
        calculate_spawn_chances.each do |gem, percent|
          puts " #{gem.ljust(12)}: #{percent}%"
        end
      when "4"
        puts "\nThanks for playing! Final Wallet: $#{@wallet}."#display a farewell message and the player's final wallet amount
        break
      else
        puts "\n⚠️ Invalid choice. Please enter 1, 2, 3, or 4."#display an error message for invalid input
      end
    end
  end
end

# Fire up the game
GemMiningGame.new.play#run the game by creating a new instance of GemMiningGame and calling the play method
