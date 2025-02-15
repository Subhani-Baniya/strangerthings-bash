#!/bin/bash

# Terminal setup
COLS=$(tput cols)
LINES=$(tput lines)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)

# Game variables
health=100
max_health=100
powers=0
max_powers=150
inventory=()
has_defeated_mindflayer=false
location_complete=(false false false false)
knowledge=0
experience=0
level=1
gold=0
achievements=()

# Utility functions
center_text() {
    printf "%*s\n" $(( (COLS + ${#1}) / 2 )) "$1"
}

center_block() {
    local IFS=$'\n'
    local lines=($1)
    local max_length=0
    
    for line in "${lines[@]}"; do
        clean_line=$(echo -e "$line" | sed 's/\x1b\[[0-9;]*m//g')
        [ ${#clean_line} -gt $max_length ] && max_length=${#clean_line}
    done
    
    local padding=$(( (COLS - max_length) / 2 ))
    
    for line in "${lines[@]}"; do
        printf "%${padding}s%s\n" "" "$line"
    done
}

get_random_error_message() {
    local messages=(
        "${RED}Hmm... that doesn't seem right. Try again!${RESET}"
        "${RED}That's not a valid choice. Maybe check the menu?${RESET}"
        "${RED}Sorry, I didn't understand that. Please select from the options shown.${RESET}"
        "${RED}Oops! That's not one of the available choices.${RESET}"
        "${RED}Invalid input detected. Let's try that again!${RESET}"
        "${RED}That's not going to work. Pick a valid option please!${RESET}"
        "${RED}Error 11: Just kidding! But seriously, that's not a valid choice.${RESET}"
        "${RED}*bzzt* Invalid selection. Please recalibrate your choice.${RESET}"
        "${RED}The Mind Flayer would make a better choice than that! Try again.${RESET}"
        "${RED}Even Dustin knows that's not a valid option!${RESET}"
    )
    echo "${messages[$((RANDOM % ${#messages[@]}))]}"
}

add_achievement() {
    local achievement=$1
    if [[ ! " ${achievements[*]} " =~ " ${achievement} " ]]; then
        achievements+=("$achievement")
        echo "${YELLOW}Achievement Unlocked: $achievement!${RESET}"
        experience=$((experience + 50))
        check_level_up
    fi
}

check_level_up() {
    local required_exp=$((level * 100))
    if [ $experience -ge $required_exp ]; then
        level=$((level + 1))
        max_health=$((max_health + 20))
        health=$max_health
        powers=$((powers + 10))
        echo "${GREEN}Level Up! You are now level $level!${RESET}"
        echo "Health and powers increased!"
        case $level in
            5) add_achievement "Rising Star";;
            10) add_achievement "Veteran Explorer";;
            15) add_achievement "Master of Hawkins";;
        esac
        add_achievement "Reached Level $level"
    fi
}

show_shop() {
    while true; do
        clear
        echo "${YELLOW}╔══════════════════════════════════════╗${RESET}"
        echo "${YELLOW}║${RESET}         HAWKINS SHOP                 ${YELLOW}║${RESET}"
        echo "${YELLOW}╠══════════════════════════════════════╣${RESET}"
        echo "${YELLOW}║${RESET} 1. Healing Potion    (50g) ❤️         ${YELLOW}║${RESET}"
        echo "${YELLOW}║${RESET} 2. Power Crystal     (75g) ⚡        ${YELLOW}║${RESET}"
        echo "${YELLOW}║${RESET} 3. Strength Potion   (100g) 💪       ${YELLOW}║${RESET}"
        echo "${YELLOW}║${RESET} 4. Shield Charm      (150g) 🛡️        ${YELLOW}║${RESET}"
        echo "${YELLOW}║${RESET} 5. Leave Shop                        ${YELLOW}║${RESET}"
        echo "${YELLOW}╚══════════════════════════════════════╝${RESET}"
        
        read -p "What would you like to buy? " choice
        
        case $choice in
            1) [ $gold -ge 50 ] && { inventory+=("healing_potion"); gold=$((gold - 50)); echo "${GREEN}Purchased Healing Potion!${RESET}"; } || echo "${RED}Not enough gold!${RESET}";;
            2) [ $gold -ge 75 ] && { max_powers=$((max_powers + 10)); powers=$((powers + 10)); gold=$((gold - 75)); echo "${GREEN}Purchased Power Crystal!${RESET}"; } || echo "${RED}Not enough gold!${RESET}";;
            3) [ $gold -ge 100 ] && { inventory+=("strength_potion"); gold=$((gold - 100)); echo "${GREEN}Purchased Strength Potion!${RESET}"; } || echo "${RED}Not enough gold!${RESET}";;
            4) [ $gold -ge 150 ] && { inventory+=("shield_charm"); gold=$((gold - 150)); echo "${GREEN}Purchased Shield Charm!${RESET}"; } || echo "${RED}Not enough gold!${RESET}";;
            5) return;;
            *) get_random_error_message;;
        esac
        sleep 1
    done
}

show_title() {
    clear
    local title_art="
            ███████╗████████╗██████╗  █████╗ ███╗   ██╗ ██████╗ ███████╗██████╗     
            ██╔════╝╚══██╔══╝██╔══██╗██╔══██╗████╗  ██║██╔════╝ ██╔════╝██╔══██╗    
            ███████╗   ██║   ██████╔╝███████║██╔██╗ ██║██║  ███╗█████╗  ██████╔╝    
            ╚════██║   ██║   ██╔══██╗██╔══██║██║╚██╗██║██║   ██║██╔══╝  ██╔══██╗    
            ███████║   ██║   ██║  ██║██║  ██║██║ ╚████║╚██████╔╝███████╗██║  ██║    
            ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝    
                                                                                    
                     ████████╗██╗  ██╗██╗███╗   ██╗ ██████╗ ███████╗                         
                     ╚══██╔══╝██║  ██║██║████╗  ██║██╔════╝ ██╔════╝                         
                        ██║   ███████║██║██╔██╗ ██║██║  ███╗███████╗                         
                        ██║   ██╔══██║██║██║╚██╗██║██║   ██║╚════██║                         
                        ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║                         
                        ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝                         
                                                                                    
                                   ╔═══════════════════╗                                 
                                ╔══╣  A DARK ADVENTURE ╠══╗                              
                                ║  ╚═══════════════════╝  ║                              
                                ║        IN HAWKINS       ║                              
                                ╚═════════════════════════╝                              
"
    echo "${BLUE}$(center_block "$title_art")${RESET}"
    center_text "Press any key to start..."
    read -n 1
}

show_mall() {
    local mall_art="
    ╔════════════════════════════╗    
    ║      S T A R C O U R T     ║    
    ║          M A L L           ║    
    ╠════════════════════════════╣    
    ║  ┌────┐  ┌────┐  ┌────┐    ║    
    ║  │    │  │    │  │    │    ║    
    ║  └────┘  └────┘  └────┘    ║    
    ║     ╔════════════════╗     ║    
    ║     ║  SCOOPS AHOY!  ║     ║    
    ║     ║   ╔═══╗ ╔═══╗  ║     ║    
    ║     ║   ║   ║ ║   ║  ║     ║    
    ║     ╚═══╩═══╩═╩═══╩══╝     ║    
    ╚════════════════════════════╝    
"
    echo "${CYAN}$(center_block "$mall_art")${RESET}"
}

show_basement() {
    local art="
    ╔═══════════════════════════════╗
    ║     WHEELER'S BASEMENT        ║
    ╠═══════════════════════════════╣
    ║     ┌─────────────────┐       ║
    ║     │   D&D TABLE     │       ║
    ║     │    ╭─────╮      │       ║
    ║     │    │ □ □ │      │       ║
    ║     │    │ □ □ │      │       ║
    ║     │    ╰─────╯      │       ║
    ║     └─────────────────┘       ║
    ║                               ║
    ╚═══════════════════════════════╝    
    "
    echo "${GREEN}$(center_block "$art")${RESET}"
}

show_police() {
    local art="
    ╔═════════════════════════════╗    
    ║      HAWKINS POLICE         ║    
    ║         ┌───────┐           ║    
    ║         │ H.P.D │           ║    
    ║         └───────┘           ║    
    ║  ┌────┐    ┌──┐    ┌────┐   ║    
    ║  │    │    │▓▓│    │    │   ║
    ║  │    │    │▓▓│    │    │   ║    
    ║  └────┘    └──┘    └────┘   ║    
    ╚═════════════════════════════╝
    "
    echo "${BLUE}$(center_block "$art")${RESET}"
}

show_upside_down() {
    local art="
    ⌐╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨╮    
    ╟▓▓░▓▒░▓▓░▓▒░▓▓░▓▒░▓▓░▓▒░▓▓░▓▒░▓╢    
    ╟▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓╢    
    ║  T H E  U P S I D E  D O W N  ║    
    ╟▒░▓▒░▓▒░▓▒░▓▒░▓▒░▓▒░▓▒░▓▒░▓▒░▓░╢    
    ╟▓▒░▓▓░▓▒░▓▓░▓▒░▓▓░▓▒░▓▓░▓▒░▓▓░▓╢    
    ╟▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓░▒▓╢    
    └╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥─╨─╥┘    
    "
    echo "${RED}$(center_block "$art")${RESET}"
}

show_lab() {
    local art="
    ╔══════════════════════════╗    
    ║   HAWKINS NATIONAL LAB   ║    
    ╠══════════════════════════╣    
    ║  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ║    
    ║  │██│  │██│  │██│  │██│  ║    
    ║  └──┘  └──┘  └──┘  └──┘  ║    
    ║                          ║    
    ║  ┌──┐  ┌──┐  ┌──┐  ┌──┐  ║    
    ║  │██│  │██│  │██│  │██│  ║    
    ║  └──┘  └──┘  └──┘  └──┘  ║    
    ║          ╔════╗          ║    
    ║          ║ •• ║          ║ 
    ╚══════════╝    ╚══════════╝
    "
    echo "${YELLOW}$(center_block "$art")${RESET}"
}

type_text() {
    local text="$1"E
    local speed=${2:-0.03}
    local text_length=${#text}
    local padding=$(( (COLS - text_length) / 2 ))
    
    [ $padding -lt 0 ] && padding=0
    printf "%*s" "$padding" ""
    
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep $speed
    done
    echo
}

show_health_bar() {
    local current=$1
    local max=$2
    local width=40
    local percentage=$((current * width / max))
    local bar=""
    
    if [ $current -gt $((max * 7 / 10)) ]; then
        local color=$GREEN
    elif [ $current -gt $((max * 3 / 10)) ]; then
        local color=$YELLOW
    else
        local color=$RED
    fi
    
    printf "%s[" "$color"
    for ((i=0; i<width; i++)); do
        [ $i -lt $percentage ] && printf "█" || printf "░"
    done
    printf "]%s %d/%d" "$RESET" "$current" "$max"
}

show_status() {
    echo "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo "${CYAN}║${RESET}                         STATUS                             ${CYAN}║${RESET}"
    echo "${CYAN}╠════════════════════════════════════════════════════════════╣${RESET}"
    echo -n "${CYAN}${RESET} Health: "
    show_health_bar $health $max_health
    echo "   ${CYAN}${RESET}"
    echo -n "${CYAN}${RESET} Powers: "
    show_health_bar $powers $max_powers
    echo "   ${CYAN}${RESET}"
    echo "             ${CYAN}${RESET} Level: $level | XP: $experience/$(($level * 100)) | ${RESET} Gold: ${YELLOW}$gold${RESET}    ${CYAN}${RESET}"
    echo "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
}

show_enhanced_inventory() {
    echo "${MAGENTA}╔════════════════════════════════════════╗${RESET}"
    echo "${MAGENTA}║${RESET}             INVENTORY                  ${MAGENTA}║${RESET}"
    echo "${MAGENTA}╠════════════════════════════════════════╣${RESET}"
    [ ${#inventory[@]} -eq 0 ] && echo "${MAGENTA}${RESET} Empty                                ${MAGENTA}${RESET}" || for item in "${inventory[@]}"; do
        printf "${MAGENTA}${RESET} %-36s ${MAGENTA}${RESET}\n" "• ${item}"
    done
    echo "${MAGENTA}╚════════════════════════════════════════╝${RESET}"
}

show_enhanced_achievements() {
    clear
    echo "${GREEN}╔════════════════════════════════════════╗${RESET}"
    echo "${GREEN}║${RESET}           ACHIEVEMENTS                ${GREEN}║${RESET}"
    echo "${GREEN}╠════════════════════════════════════════╣${RESET}"
    [ ${#achievements[@]} -eq 0 ] && echo "${GREEN}${RESET} No achievements yet                  ${GREEN}${RESET}" || for achievement in "${achievements[@]}"; do
        printf "${GREEN}${RESET} %-36s ${GREEN}${RESET}\n" "🏆 $achievement"
    done
    echo "${GREEN}╚════════════════════════════════════════╝${RESET}"
    echo "Press Enter to continue..."
    read -n 1
}

show_loading_animation() {
    local text=$1
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    for i in {1..20}; do
        printf "\r${CYAN}%s${RESET} %s" "${frames[i % 10]}" "$text"
        sleep 0.1
    done
    printf "\n"
}

show_location_transition() {
    local location=$1
    clear
    echo "${BLUE}╔═══════════════════════════════════════════════╗${RESET}"
    echo "${BLUE}${RESET}      Traveling to $location...        ${BLUE}${RESET}"
    echo "${BLUE}╚═══════════════════════════════════════════════╝${RESET}"
    show_loading_animation "Loading..."
}

play_wire_game() {
    echo "=== WIRE CONNECTING CHALLENGE ==="
    echo "Connect the colored wires in the correct order."
    
    local colors=("RED" "GREEN" "YELLOW" "BLUE")
    local sequence=()
    
    for i in {1..4}; do
        sequence+=("${colors[$((RANDOM % 4))]}")
    done
    
    echo "Memorize the sequence:"
    for color in "${sequence[@]}"; do
        printf "%s■%s " "${!color}" "$RESET"
    done
    echo
    sleep 3
    clear
    
    local player_sequence=()
    for i in {1..4}; do
        read -p "Enter color $i (r/g/y/b): " -n 1 choice
        echo  
        case $choice in
            r) player_sequence+=("RED");;
            g) player_sequence+=("GREEN");;
            y) player_sequence+=("YELLOW");;
            b) player_sequence+=("BLUE");;
        esac
    done
    
    for i in {0..3}; do
        [ "${sequence[$i]}" != "${player_sequence[$i]}" ] && return 1
    done
    return 0
}

play_memory_game() {
    echo "=== PSYCHIC TRAINING ==="
    echo "Remember the symbols..."
    local symbols=("@" "#" "$" "%" "&" "*")
    local sequence=()
    
    for i in {1..4}; do
        sequence+=("${symbols[$((RANDOM % 6))]}")
    done
    
    for symbol in "${sequence[@]}"; do
        echo -n "$symbol "
    done
    sleep 2
    clear
    
    echo "Enter the symbols in order:"
    read player_input
    
    local correct_sequence=$(printf "%s" "${sequence[@]}")
    
    [ "${player_input// /}" = "$correct_sequence" ]
    return $?
}

play_riddle_game() {
    local riddles=(
        "I have cities, but no houses. I have mountains, but no trees. I have water, but no fish. I have roads, but no cars. What am I?:map"
        "What has keys, but no locks; space, but no room; and you can enter, but not go in?:keyboard"
        "What gets bigger when more is taken away?:hole"
    )
    
    local riddle=${riddles[$((RANDOM % ${#riddles[@]}))]}
    local question=${riddle%:*}
    local answer=${riddle#*:}
    
    echo "=== RIDDLE CHALLENGE ==="
    type_text "$question"
    read -p "Your answer: " player_answer
    
    [ "${player_answer,,}" = "$answer" ]
    return $?
}

play_combat() {
    local enemy_health=100
    local enemy_name=$1
    local enemy_level=${2:-1}
    local turn=1
    local status_effects=()
    
    enemy_health=$((enemy_health + (enemy_level * 20)))
    
    type_text "A level $enemy_level $enemy_name appears!"
    
    while [ $enemy_health -gt 0 ] && [ $health -gt 0 ]; do
        clear
        echo "${RED}=== COMBAT VS $enemy_name (Level $enemy_level) === (Turn $turn)${RESET}"
        show_status
        
        local health_bar=""
        local health_percentage=$((enemy_health * 20 / (100 + (enemy_level * 20))))
        for ((i=0; i<20; i++)); do
            [ $i -lt $health_percentage ] && health_bar+="█" || health_bar+="░"
        done
        echo "Enemy Health: $health_bar ($enemy_health)"
        
        echo
        echo "1. Quick Attack (Low damage, high accuracy)"
        echo "2. Heavy Attack (High damage, low accuracy)"
        echo "3. Special Ability ($powers powers)"
        echo "4. Use Item"
        echo "5. Defend (Reduce damage next turn)"
        read -p "Action: " choice

        [[ " ${status_effects[*]} " =~ "defending" ]] && status_effects=("${status_effects[@]/defending}")

        case $choice in
            1)  [ $((RANDOM % 100)) -lt 90 ] && { damage=$((RANDOM % 6 + 10 + (level * 2))); enemy_health=$((enemy_health - damage)); type_text "Quick strike hits for $damage damage!"; experience=$((experience + 5)); } || type_text "Attack missed!";;
            2)  [ $((RANDOM % 100)) -lt 60 ] && { damage=$((RANDOM % 11 + 20 + (level * 3))); enemy_health=$((enemy_health - damage)); type_text "Powerful blow connects for $damage damage!"; experience=$((experience + 10)); } || type_text "Heavy attack missed!";;
            3)  if [ $powers -ge 20 ]; then
                    echo "Choose special ability:"
                    echo "1. Psychic Blast (20 powers) - High damage"
                    echo "2. Heal (20 powers) - Restore health"
                    echo "3. Stun (30 powers) - Enemy skips next turn"
                    read -p "Choice: " ability_choice
                    
                    case $ability_choice in
                        1)  damage=$((powers + (level * 5))); enemy_health=$((enemy_health - damage)); powers=$((powers - 20)); type_text "Psychic blast deals $damage damage!"; experience=$((experience + 15));;
                        2)  local heal_amount=$((30 + (level * 5))); health=$((health + heal_amount)); [ $health -gt $max_health ] && health=$max_health; powers=$((powers - 20)); type_text "Healed for $heal_amount health!";;
                        3)  [ $powers -ge 30 ] && { status_effects+=("stunned"); powers=$((powers - 30)); type_text "Enemy is stunned!"; } || type_text "Not enough powers!";;
                    esac
                else
                    type_text "Not enough powers!"
                fi
                ;;
            4)  if [ ${#inventory[@]} -eq 0 ]; then
                    type_text "No items available!"
                else
                    echo "Choose item to use:"
                    for i in "${!inventory[@]}"; do
                        echo "$((i+1)). ${inventory[$i]}"
                    done
                    read -p "Choice: " item_choice
                    item_choice=$((item_choice-1))
                    
                    if [ $item_choice -ge 0 ] && [ $item_choice -lt ${#inventory[@]} ]; then
                        case ${inventory[$item_choice]} in
                            "healing_potion") health=$((health + 50)); [ $health -gt $max_health ] && health=$max_health; type_text "Used healing potion! Restored 50 health!";;
                            "strength_potion") damage=$((RANDOM % 30 + 40 + (level * 5))); enemy_health=$((enemy_health - damage)); type_text "Used strength potion! Dealt $damage damage!";;
                            "shield_charm") status_effects+=("shielded"); type_text "Shield charm activated! Damage reduction active!";;
                        esac
                        inventory=("${inventory[@]:0:$item_choice}" "${inventory[@]:$((item_choice + 1))}")
                    fi
                fi
                ;;
            5)  status_effects+=("defending"); type_text "Defending against next attack!";;
            *)  get_random_error_message;;
        esac
        
        if [ $enemy_health -gt 0 ] && [[ ! " ${status_effects[*]} " =~ "stunned" ]]; then
            local enemy_damage
            [ $((turn % 3)) -eq 0 ] && enemy_damage=$((RANDOM % 20 + 15 + (enemy_level * 3))) && type_text "$enemy_name uses a special attack!" || enemy_damage=$((RANDOM % 10 + 5 + (enemy_level * 2))) && type_text "$enemy_name attacks!"
            
            [[ " ${status_effects[*]} " =~ "defending" ]] && enemy_damage=$((enemy_damage / 2)) && echo "Defensive stance reduces damage!"
            [[ " ${status_effects[*]} " =~ "shielded" ]] && enemy_damage=$((enemy_damage * 2 / 3)) && echo "Shield charm reduces damage!"
            
            health=$((health - enemy_damage))
            echo "You take $enemy_damage damage!"
        fi
        
        status_effects=("${status_effects[@]/stunned}")
        turn=$((turn + 1))
        sleep 1
        check_level_up
    done
    
    if [ $health -gt 0 ]; then
        local gold_reward=$((RANDOM % 20 + 20 + (enemy_level * 10)))
        gold=$((gold + gold_reward))
        echo "${YELLOW}You found $gold_reward gold!${RESET}"
        add_achievement "Defeated $enemy_name"
        return 0
    fi
    return 1
}

hawkins_lab() {
    while true; do
        clear
        show_lab
        type_text "The sterile corridors of Hawkins Lab stretch before you, the fluorescent lights flickering ominously. The air is thick with the scent of antiseptic and something... unnatural. You can't shake the feeling that you're being watched. The walls are lined with cryptic symbols and warning signs, and the faint hum of machinery echoes through the halls."
        show_status
        
        echo "1. Training Room (Test Powers)"
        echo "2. Research Wing (Find Equipment)"
        echo "3. Secret Chamber"
        echo "4. Leave"
        read -p "Choice: " choice

        case $choice in
            1)  type_text "You enter the training room, where the walls are lined with strange equipment. A faint hum fills the air as you prepare to test your psychic abilities. The room feels charged with energy, and you can almost hear whispers in the back of your mind."
                if play_memory_game; then
                    echo "Power training successful!"
                    powers=$((powers + 20))
                    type_text "Your psychic abilities grow stronger, the energy coursing through you like a live wire. You feel more connected to the unseen forces around you."
                else
                    echo "Training failed."
                    health=$((health - 10))
                    type_text "The psychic feedback is overwhelming, leaving you with a splitting headache. You need to be more careful next time."
                fi
                ;;
            2)  type_text "You cautiously enter the research wing, where the walls are lined with locked cabinets and strange devices. The silence is deafening, broken only by the occasional beep of machinery. You notice a security panel with exposed wires—perhaps you can bypass it."
                if [[ ! " ${inventory[*]} " =~ "lab_keycard" ]]; then
                    if play_wire_game; then
                        echo "Found lab keycard!"
                        inventory+=("lab_keycard")
                        type_text "You manage to bypass the security system and find a lab keycard. This might come in handy for accessing restricted areas."
                        add_achievement "Security Access Granted"
                    else
                        health=$((health - 15))
                        type_text "The security system shocks you as you fumble with the wires. You need to be more careful next time."
                    fi
                else
                    type_text "You've already searched this area thoroughly. There's nothing else of interest here."
                fi
                ;;
            3)  type_text "You approach the secret chamber, a heavy door with a keycard scanner blocking your way. The air grows colder as you near it, and you can feel a faint vibration underfoot. Something powerful lies beyond this door."
                if [[ " ${inventory[*]} " =~ "lab_keycard" ]]; then
                    if play_combat "Security Guard"; then
                        echo "Accessed secret files!"
                        location_complete[0]=true
                        if [[ ! " ${inventory[*]} " =~ "ritual_dagger" ]]; then
                            inventory+=("ritual_dagger")
                            type_text "Inside the chamber, you find a mysterious ritual dagger. Its blade is cold to the touch, and you can feel a faint pulse of energy emanating from it. This could be the key to defeating the Mind Flayer."
                        fi
                    fi
                else
                    type_text "The door is securely locked. You'll need a lab keycard to enter."
                fi
                ;;
            4) return ;;
            *)  get_random_error_message ;;
        esac
        sleep 2
    done
}

starcourt_mall() {
    while true; do
        clear
        show_mall
        type_text "The abandoned Starcourt Mall looms before you, its neon signs flickering weakly in the dim light. The once-bustling food court is now eerily silent, with overturned tables and scattered debris. The air smells of decay and burnt plastic. You feel a strange presence lurking in the shadows."
        show_status
        
        echo "1. Scoops Ahoy (Search for clues)"
        echo "2. Russian Base (Investigate)"
        echo "3. Food Court (Find supplies)"
        echo "4. Leave"
        read -p "Choice: " choice

        case $choice in
            1)  type_text "You enter Scoops Ahoy, the ice cream shop now covered in a thick layer of dust. The counter is littered with old receipts and broken equipment. You notice a strange symbol carved into the wall—it looks like a clue."
                if play_riddle_game; then
                    echo "Found secret documents!"
                    knowledge=$((knowledge + 30))
                    if [[ ! " ${inventory[*]} " =~ "russian_code" ]]; then
                        inventory+=("russian_code")
                        type_text "You discover a set of Russian transmission codes hidden behind the counter. These could be crucial for accessing the Russian base."
                    fi
                else
                    health=$((health - 15))
                    type_text "You trigger an alarm system, and the sudden noise startles you. You take damage as you scramble to escape."
                fi
                ;;
            2)  type_text "You approach the entrance to the Russian base, hidden deep within the mall. The door is heavily fortified, and a keypad glows faintly in the dark. You'll need the right codes to enter."
                                if [[ " ${inventory[*]} " =~ "russian_code" ]]; then
                    if play_combat "Russian Guard"; then
                        echo "Accessed secret base!"
                        location_complete[1]=true
                        if [[ ! " ${inventory[*]} " =~ "keycard_7b" ]]; then
                            inventory+=("keycard_7b")
                            type_text "Inside the base, you find a security keycard labeled '7B.' This could grant you access to even more restricted areas."
                        fi
                    fi
                else
                    type_text "The door is locked, and you don't have the necessary codes to enter. You'll need to find them elsewhere."
                fi
                ;;
            3)  type_text "You search the food court, rummaging through the abandoned stalls. Among the debris, you find a first aid kit tucked under a counter."
                health=$((health + 20))
                [ $health -gt $max_health ] && health=$max_health
                type_text "You restore 20 health! The supplies are limited, but every bit helps in this dangerous world."
                ;;
            4) return ;;
            *)  get_random_error_message ;;
        esac
        sleep 2
    done
}

wheelers_basement() {
    while true; do
        clear
        show_basement
        type_text "The familiar D&D table sits in the middle of the basement, surrounded by maps, dice, and character sheets. The walls are covered in posters of fantasy creatures and handwritten notes. This place feels like a sanctuary, but you know the danger outside is never far away."
        show_status
        
        echo "1. Research Monster Manual"
        echo "2. Practice Telekinesis"
        echo "3. Contact Party Members"
        echo "4. Leave"
        read -p "Choice: " choice

        case $choice in
            1)  type_text "You open the Monster Manual, flipping through its pages. The illustrations of Mind Flayers and Demogorgons seem more real than ever. You study their weaknesses and strategies."
                knowledge=$((knowledge + 20))
                type_text "You gain valuable knowledge about the creatures you're facing. Knowledge is power in this fight."
                ;;
            2)  type_text "You focus your mind, trying to lift objects with your telekinetic abilities. The room feels charged with energy as you concentrate."
                if play_memory_game; then
                    powers=$((powers + 30))
                    type_text "Your telekinetic abilities improve! You feel more in control of your powers."
                else
                    health=$((health - 15))
                    type_text "The psychic feedback overwhelms you, leaving you with a headache. You need to be more careful."
                fi
                ;;
            3)  type_text "You pick up the walkie-talkie, hoping to contact your friends. Static fills the air as you try to establish a connection."
                if play_riddle_game; then
                    type_text "You hear a familiar voice crackling through the static. It's your party! They provide valuable information and boost your morale."
                    inventory+=("walkie_talkie")
                    health=$((health + 25))
                    [ $health -gt $max_health ] && health=$max_health
                else
                    type_text "The static continues, and no one responds. You feel a pang of loneliness."
                fi
                ;;
            4) return ;;
            *)  get_random_error_message ;;
        esac
        sleep 2
    done
}

hawkins_pd() {
    while true; do
        clear
        show_police
        type_text "The Hawkins Police Department feels eerily quiet, with overturned desks and scattered papers. The faint sound of a police radio crackles in the background, but no one is here to answer the calls. The air smells of gunpowder and something... metallic."
        show_status
        
        echo "1. Investigate Holding Cells"
        echo "2. Search Evidence Room"
        echo "3. Access Chief's Office"
        echo "4. Leave"
        read -p "Choice: " choice

        case $choice in
            1)  type_text "You cautiously approach the holding cells. The air grows colder as you near them, and you hear faint growling from within."
                if play_combat "Demogorgon"; then
                    echo "Found prison keys!"
                    inventory+=("cell_keys")
                    type_text "You defeat the Demogorgon and find a set of prison keys. These might unlock something important."
                fi
                ;;
            2)  type_text "You approach the evidence room, its door securely locked. The faint glow of a security panel catches your eye."
                if [[ " ${inventory[*]} " =~ "cell_keys" ]]; then
                    echo "Discovered protective gear!"
                    inventory+=("protective_amulet")
                    location_complete[3]=true
                    type_text "Inside the evidence room, you find a protective amulet. Its energy feels calming, as if it can shield you from the darkness."
                else
                    type_text "The evidence room is securely locked. You'll need the right keys to enter."
                fi
                ;;
            3)  type_text "You enter Chief Hopper's office, the desk cluttered with case files and photos of missing persons. The walls are covered in maps and notes about strange occurrences."
                knowledge=$((knowledge + 40))
                type_text "You review the case files, learning about the government's coverups and the true extent of the Upside Down's influence."
                ;;
            4) return ;;
            *)  get_random_error_message ;;
        esac
        sleep 2
    done
}

upside_down() {
    clear
    echo "${RED}=== THE UPSIDE DOWN ===${RESET}"
    type_text "The air grows thick with malevolence as you step into the Upside Down. The twisted versions of familiar locations are shrouded in darkness, and the ground feels unstable beneath your feet. You can hear distant whispers and the occasional growl of unseen creatures. This is the heart of the darkness."
    
    if [[ ! " ${inventory[*]} " =~ "ritual_dagger" ]] || 
       [[ ! " ${inventory[*]} " =~ "protective_amulet" ]] || 
       [ $powers -lt 75 ]; then
        type_text "You're not prepared for this darkness..."
        type_text "Required: Ritual Dagger, Protective Amulet, and Powers > 75"
        return
    fi
    
    sleep 1
    
    # Multi-phase boss battle
    local phase=1
    local mindflayer_health=200
    
    while [ $phase -le 3 ] && [ $health -gt 0 ] && [ $mindflayer_health -gt 0 ]; do
        clear
        echo "${RED}=== MIND FLAYER BATTLE - PHASE $phase ===${RESET}"
        
        case $phase in
            1)  type_text "The Mind Flayer manifests through a storm of shadows, its massive form towering over you. You feel its psychic presence pressing against your mind."
                if ! play_wire_game; then
                    health=$((health - 30))
                    type_text "Failed to establish psychic barrier! The Mind Flayer's presence overwhelms you, causing significant damage."
                fi
                ;;
            2)  type_text "Reality warps around you as the Mind Flayer's power grows. The ground beneath you shifts, and you struggle to maintain your footing."
                if ! play_memory_game; then
                    health=$((health - 40))
                    type_text "The psychic assault overwhelms you, leaving you disoriented and vulnerable."
                fi
                ;;
            3)  type_text "The final confrontation begins! The Mind Flayer's form becomes more solid, its eyes glowing with malevolent energy. You grip the ritual dagger tightly, knowing this is your only chance."
                if play_combat "Mind Flayer"; then
                    has_defeated_mindflayer=true
                    add_achievement "Hero of Hawkins"
                    return
                fi
                ;;
        esac
        
        phase=$((phase + 1))
        read -p "Press Enter to continue..."
    done
}

# Main game loop
main() {
    show_title
    type_text "Chapter 1: The Mysterious Disappearances" 0.05
    sleep 2
    
    while true; do
        clear
        echo "${MAGENTA}╔═════════════════════════════════════╗${RESET}"
        echo "${MAGENTA}║${RESET}           MAIN MENU                 ${MAGENTA}║${RESET}"
        echo "${MAGENTA}╠═════════════════════════════════════╣${RESET}"
        echo "${MAGENTA}║${RESET} 1. Hawkins National Laboratory      ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 2. Starcourt Mall                   ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 3. Wheeler's Basement               ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 4. Hawkins Police Department        ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 5. The Upside Down (Final Battle)   ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 6. Shop                             ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 7. View Achievements                ${MAGENTA}║${RESET}"
        echo "${MAGENTA}║${RESET} 8. Quit                             ${MAGENTA}║${RESET}"
        echo "${MAGENTA}╚═════════════════════════════════════╝${RESET}"
        
        show_status
        show_enhanced_inventory
        
        read -p "Where will you go? " choice
        
        case $choice in
            1) show_location_transition "Hawkins Lab" && hawkins_lab ;;
            2) show_location_transition "Starcourt Mall" && starcourt_mall ;;
            3) show_location_transition "Wheeler's Basement" && wheelers_basement ;;
            4) show_location_transition "Police Department" && hawkins_pd ;;
            5) show_location_transition "The Upside Down" && upside_down ;;
            6) show_shop ;;
            7) show_enhanced_achievements ;;
            8) exit 0 ;;
            *) get_random_error_message ;;
        esac
        
        if $has_defeated_mindflayer; then
            clear
            echo "${GREEN}╔══════════════════════════════════════╗${RESET}"
            echo "${GREEN}║${RESET}         VICTORY ACHIEVED             ${GREEN}║${RESET}"
            echo "${GREEN}╠══════════════════════════════════════╣${RESET}"
            echo "${GREEN}║${RESET} You've banished the Mind Flayer!     ${GREEN}║${RESET}"
            echo "${GREEN}║${RESET} The town is safe... for now.         ${GREEN}║${RESET}"
            echo "${GREEN}╚══════════════════════════════════════╝${RESET}"
            sleep 3
            exit 0
        elif [ $health -le 0 ]; then
            clear
            echo "${RED}╔══════════════════════════════════════╗${RESET}"
            echo "${RED}║${RESET}           GAME OVER                  ${RED}║${RESET}"
            echo "${RED}╠══════════════════════════════════════╣${RESET}"
            echo "${RED}║${RESET} Your vision fades to black...        ${RED}║${RESET}"
            echo "${RED}║${RESET} The darkness has claimed another...  ${RED}║${RESET}"
            echo "${RED}╚══════════════════════════════════════╝${RESET}"
            sleep 3
            exit 0
        fi
    done
}

# Start the game 
main