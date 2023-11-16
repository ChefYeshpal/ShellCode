#made by github.com/ChefYeshpal
#this program just converts words that you type into morsecode... maybe i'll implement it into arduino

#!/bin/bash

declare -A morsecode

#morse code mappings
morsecode["A"]=".−"
morsecode["B"]="-..."
morsecode["C"]="-.-."
morsecode["D"]="-.."
morsecode["E"]="."
morsecode["F"]="..-."
morsecode["G"]="--."
morsecode["H"]="...."
morsecode["I"]=".."
morsecode["J"]=".---"
morsecode["K"]="-.-"
morsecode["L"]=".-.."
morsecode["M"]="--"
morsecode["N"]="-."
morsecode["O"]="---"
morsecode["P"]=".--."
morsecode["Q"]="--.-"
morsecode["R"]=".-."
morsecode["S"]="..."
morsecode["T"]="-"
morsecode["U"]="..-"
morsecode["V"]="...-"
morsecode["W"]=".--"
morsecode["X"]="-..-"
morsecode["Y"]="-.--"
morsecode["Z"]="--.."
morsecode["1"]=".----"
morsecode["2"]="..---"
morsecode["3"]="...--"
morsecode["4"]="....-"
morsecode["5"]="....."
morsecode["6"]="-...."
morsecode["7"]="--..."
morsecode["8"]="---.."
morsecode["9"]="----."
morsecode["0"]="-----"

# Function to convert a single character to Morse code
char_to_morse() {
    local char=$1
    echo -n "${morsecode[$char]} "
}

# Function to convert a word to Morse code
word_to_morse() {
    local word=$1
    local morse=""
    
    for ((i=0; i<${#word}; i++)); do
        char="${word:$i:1}"
        if [ "$char" != " " ]; then
            morse+="$(char_to_morse "$char")"
        else
            morse+="   "  # Add three spaces for word spacing in Morse code
        fi
    done

    echo "$morse"
}

# Main script
read -p "Enter a your sentence: " input_word

# Convert the input word to uppercase for simplicity
uppercase_word=$(echo "$input_word" | tr '[:lower:]' '[:upper:]')

# Call the function to convert the word to Morse code
result=$(word_to_morse "$uppercase_word")

# Print the result
echo "Morse code for '$input_word': "
echo "	$result"








