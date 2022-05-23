#Jakob Klint, 3B
#Foodplanner, projekt 1, Tillämpad programmering.

require 'date'

class Date
    def dayname
       DAYNAMES[self.wday]
    end
end

#-------------------------------------------------------------------

def new_food(foods, prev_spin, weekspins) #Definerar funktion för att ta fram ny maträtt för dagen.
    food = prev_spin
    while food == prev_spin
        food = foods[rand(0..foods.length-1)]
    end

    puts "> Randomizing."
    sleep 0.5
    puts "Your food for today is: #{food}."

    if weekspins != "0" && weekspins != 0 #kollar om man har "weekly spins" kvar
        puts "You have #{weekspins} weekly spin(s)."
    else
        puts "You have no weekly spins left."
    end

    File.truncate("spins/dayspin.txt", 0) #Tömmer text-filen
    open("spins/dayspin.txt", 'a') do |f|
        f.puts Date.today
        f.puts food
    end
    puts "Press [Enter] to return to menu."
    gets
    menu()
end

def randomize()
    today = Date.today.dayname
    week = Date.today.cweek
    puts "Today is: #{today}."
    
    #Kollar om det är en ny vecka och ger då nya "weekly spins."
    weekspins = File.readlines("spins/weekspins.txt").map(&:chomp) #Sätter raderna från text-filen i en lista.
    if weekspins[0] != "#{week}" #Kollar om det är ny vecka.
        weekspins[1] = "2"
    end
    
    foods = File.readlines("days/#{today}.txt").map(&:chomp) #Sätter raderna från text-filen i en lista.
    if foods.uniq.length > 1
        dayspin = File.readlines("spins/dayspin.txt").map(&:chomp) #Sätter raderna från text-filen i en lista.
        
        if dayspin[0] == "#{Date.today}" #Kollar om man slumpat mat idag.
            puts "You have already randomized a meal for today!"
            puts "Your food for today was: #{dayspin[1]}."
            sleep 0.8
            if weekspins[1] != "0" && weekspins[1] != 0 #kollar om man har "weekly spins" kvar
                puts "You have #{weekspins[1]} weekly spin(s) left."
                puts 'Write "yes" to use one.'
                puts 'Press [Enter] to cancel.'
                action = gets.chomp
                if action == "yes"
                    sleep 0.8
                    weekspins[1] = weekspins[1].to_i-1
                    new_food(foods, dayspin[1],  weekspins[1]) #Callar funktionen new_food.
                else
                    menu()
                end
                File.truncate("spins/weekspins.txt", 0) #Tömmer text-filen
                open("spins/weekspins.txt", 'a') do |f| #Sätter in vecka och två vecko-spins i text-filen.
                    f.puts week
                    f.puts weekspins[1]
                end
            else
                puts "You have no weekly spins left."
                menu()
            end
        else
            new_food(foods, dayspin[1], weekspins[1]) #callar funktionen new_food.
        end
    elsif foods.uniq.length == 1
        puts "The only item in today's list is: #{foods[0]}."
        menu()
    else
        puts 'Your list for today is empty! To edit your lists, type "1".'
    end
end

#---------------------------------------------------------------------------

def edit_list()
    day = ""
    i = 0
    j = 0
    item = ""
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

    puts "What day would you like to edit?"
    puts "1 = Monday"
    puts "2 = Tuesday"
    puts "3 = Wednesday"
    puts "4 = Thursday"
    puts "5 = Friday"
    puts "6 = Saturday"
    puts "7 = Sunday"
    
    while day != "1" && day != "2" && day != "3" && day != "4" && day != "5" && day != "6" && day != "7"
        user_input = gets.chomp
        #puts user_input
        day = user_input
        if day != "1" && day != "2" && day != "3" && day != "4" && day != "5" && day != "6" && day != "7"
            puts "Your input must exist in the list! Try again."
        end
    end

    puts "You chose to edit #{days[day.to_i-1]}."
    temp_foods = File.readlines("days/#{days[day.to_i-1]}.txt").map(&:chomp) #Sätter raderna från text-filen i en lista.
    
    
    while item != "back" && item != "q" && item != "quit"
        g = 0
        h = 0
        sleep 0.8
        if temp_foods != []
            puts "This is what your #{days[day.to_i-1]} looks like:"
            puts "---------------------------"
            unique_food = temp_foods.uniq
            while h < unique_food.length
                puts unique_food[h]+" [#{temp_foods.count(unique_food[h])}/5]"
                h += 1
            end
        else
            puts "---------------------------"
            puts "Your #{days[day.to_i-1]} is empty. Add an item!"
        end

        puts "---------------------------"
        puts "Write the name of the item you would like to add/edit."
        puts 'Write "clear" to clear the list.'
        puts 'Write "back" to save and retun to menu.'

        item = gets.chomp
            
        if item != "back" && item != "q" && item != "quit" && item != "clear"
            if temp_foods.include? item
                puts "---------------------------"
                puts "You can change your rating of #{item} on a scale of 1-5,"
                puts "or remove #{item} by typing "+'"-"'
                edit = gets.chomp
                if edit == "-"
                    temp_foods.delete(item)
                    puts "> Removing #{item} from your #{days[day.to_i-1]}."
                elsif edit.to_i <= 5 && edit.to_i >= 1                   
                    temp_foods.delete(item)
                    
                    while g < edit.to_i
                        temp_foods.append(item)
                        g += 1
                    end
                
                else
                    puts "Wrong input."    
                end
            else
                puts "On a scale of 1-5, how often do you want to be served #{item}?"
                scale = gets.chomp.to_i
                    
                if scale <= 5 && scale >= 1
                    while g < scale
                        temp_foods.append(item)
                        g += 1
                    end

                    puts "> Adding #{item} to your #{days[day.to_i-1]}."
                    sleep 0.8
                else
                    puts "Wrong input."
                    sleep 0.4
                end

            end
        elsif item == "clear"
            sleep 0.5
            puts "[!] This action can't be undone, are you sure that you want to clear the list?"
            sleep 1
            puts 'Write "yes" if you want to proceed.'
            puts 'Press [Enter] to cancel.'
            confirm = gets.chomp
            if confirm == "yes"
                temp_foods = []
                puts "> Clearing #{days[day.to_i-1]}."
                sleep 0.8
            else
                puts "> The action was canceled."
                sleep 0.8
            end
        else
            puts "---------------------------"
            menu()
        end
    end
        File.truncate("days/#{days[day.to_i-1]}.txt", 0) #Tömmer text-filen
        open("days/#{days[day.to_i-1]}.txt", 'a') do |f|
        
            while j < temp_foods.length
                f.puts temp_foods[j]
                j += 1
            end
        
        end
    
end


def menu() #Meny-meddelande.
    sleep 1
    puts "What would you like to do?"
    puts "Type:"
    puts "0 to randomize a meal for today."
    puts "1 to edit your meals."
    puts "q to exit."
end


def input_loop() #Input-loop för programmets valaternativ.
    puts "Welcome to Food Planner!"
    menu()
    user_input = ""
    while user_input != "quit" && user_input != "q"
        user_input = gets.chomp
        if user_input == "0"
            puts "> Randomizing a meal for today."
            puts "---------------------------"
            randomize()
        elsif user_input == "1"
            puts "Edit your meals."
            puts "---------------------------"
            edit_list()
        elsif user_input == "2"
            #
        end
    end
end

input_loop() #Startar programmet.