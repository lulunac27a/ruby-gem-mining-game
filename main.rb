# gem_mining.rb

class GemMiningGame
  # Define gem tiers with their base values and dynamic luck weight multipliers
  # High weight modifier means that upgrade levels dramatically boost this gem's spawn rate
  GEM_TYPES = {
    "Coal"       => { base_value: 1,    weight_modifier: 0.0 },
    "Quartz"     => { base_value: 5,    weight_modifier: 0.2 },
    "Iron Ore"   => { base_value: 20,   weight_modifier: 0.5 },
    "Gold Ore"   => { base_value: 100,  weight_modifier: 1.0 },
    "Emerald"    => { base_value: 500,  weight_modifier: 1.8 },
    "Ruby"       => { base_value: 2500, weight_modifier: 2.8 },
    "Diamond"    => { base_value: 12500,weight_modifier: 4.0 },
    "Obsidian"   => { base_value: 75000,weight_modifier: 5.5 }
  }

  def initialize
    @wallet = 0
    @upgrade_level = 1
    @total_mined = 0
  end

  # Calculate upgrade cost using an exponential scaling formula (infinite upgrades)
  def upgrade_cost
    (50 * (1.55 ** (@upgrade_level - 1))).round
  end

  # Generates dynamic roll chances based on the current upgrade level
  def calculate_spawn_chances
    weights = {}
    
    GEM_TYPES.each do |name, properties|
      # Base probability curve that naturally decays for rare gems
      base_probability = 100.0 / (properties[:base_value] ** 0.4)
      
      # Upgrades scale up the probability of rarer gems via their weight modifiers
      upgrade_bonus = 1.0 + ((@upgrade_level - 1) * properties[:weight_modifier] * 0.15)
      
      weights[name] = base_probability * upgrade_bonus
    end

    # Normalize weights into percentage probabilities for display
    total_weight = weights.values.sum
    probabilities = {}
    weights.each { |name, weight| probabilities[name] = ((weight / total_weight) * 100).round(2) }
    probabilities
  end

  # Simulates mining a single ore using a weighted random sample
  def mine_ore
    chances = calculate_spawn_chances
    roll = rand(0.0..100.0)
    cumulative = 0.0

    chances.each do |gem_name, percentage|
      cumulative += percentage
      if roll <= cumulative
        value = GEM_TYPES[gem_name][:base_value]
        # Upgrades also grant a flat multiplier bonus to all income
        final_value = (value * (1 + (@upgrade_level - 1) * 0.1)).round
        
        @wallet += final_value
        @total_mined += 1
        
        puts "\n⛏️  [MINE] You swung your pickaxe and unearthed: #{gem_name}!"
        puts "   Base value: $#{value} -> Level Multiplier applied! Earned: $#{final_value}"
        return
      end
    end
  end

  # Purchases a tool upgrade if funds are sufficient
  def buy_upgrade
    cost = upgrade_cost
    if @wallet >= cost
      @wallet -= cost
      @upgrade_level += 1
      puts "\n✨ [UPGRADE] Success! Your mining gear is now Level #{@upgrade_level}!"
      puts "   Rare gem spawn rates and overall income multiplier have increased."
    else
      puts "\n❌ [ERROR] Insufficient funds! You need $#{cost} (Current: $#{@wallet})."
    end
  end

  # Main interactive game loop
  def play
    puts "================================================="
    puts "💎 WELCOME TO ENDLESS GEM MINER 💎"
    puts "================================================="
    
    loop do
      puts "\n-------------------------------------------------"
      puts " Wallet: $#{@wallet} | Gear Level: #{@upgrade_level} | Total Mined: #{@total_mined}"
      puts "-------------------------------------------------"
      puts " [1] Mine Ore"
      puts " [2] Upgrade Gear (Cost: $#{upgrade_cost})"
      puts " [3] Check Current Drop Chances"
      puts " [4] Exit Game"
      print " Choose an action: "
      
      choice = gets.chomp.to_s

      case choice
      when "1"
        mine_ore
      when "2"
        buy_upgrade
      when "3"
        puts "\n--- Current Dynamic Drop Rates ---"
        calculate_spawn_chances.each do |gem, percent|
          puts " #{gem.ljust(12)}: #{percent}%"
        end
      when "4"
        puts "\nThanks for playing! Final Wallet: $#{@wallet}."
        break
      else
        puts "\n⚠️ Invalid choice. Please enter 1, 2, 3, or 4."
      end
    end
  end
end

# Fire up the game
GemMiningGame.new.play
