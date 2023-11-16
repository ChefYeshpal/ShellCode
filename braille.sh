#made by: github.com/ChefYeshpal
#this code is made to convert english sentences into braille script
#date created: 16 November 2023

#!/bin/bash

declare -A braillecode

# Define Braille code mappings
braillecode["a"]="⠇"
braillecode["b"]="⠃"
braillecode["c"]="⠉"
braillecode["d"]="⠙"
braillecode["e"]="⠑"
braillecode["f"]="⠋"
braillecode["g"]="⠛"
braillecode["h"]="⠓"
braillecode["i"]="⠊"
braillecode["j"]="⠚"
braillecode["k"]="⠅"
braillecode["l"]="⠇"
braillecode["m"]="⠍"
braillecode["n"]="⠝"
braillecode["o"]="⠕"
braillecode["p"]="⠏"
braillecode["q"]="⠟"
braillecode["r"]="⠗"
braillecode["s"]="⠎"
braillecode["t"]="⠞"
braillecode["u"]="⠥"
braillecode["v"]="⠧"
braillecode["w"]="⠺"
braillecode["x"]="⠭"
braillecode["y"]="⠽"
braillecode["z"]="⠵"
braillecode["1"]="⠼⠂"
braillecode["2"]="⠼⠆"
braillecode["3"]="⠼⠒"
braillecode["4"]="⠼⠲"
braillecode["5"]="⠼⠢"
braillecode["6"]="⠼⠖"
braillecode["7"]="⠼⠶"
braillecode["8"]="⠼⠦"
braillecode["9"]="⠼⠔"
braillecode["0"]="⠼⠴"
braillecode[" "]=" "  # space

# Function to convert a single character to Braille
char_to_braille() {
    local char=$1
    echo -n "${braillecode[$char]} "
}

# Function to convert a word to Braille
word_to_braille() {
    local word=$1
    local braille=""

    for ((i=0; i<${#word}; i++)); do
        char="${word:$i:1}"
        braille+="$(char_to_braille "$char")"
    done

    echo "$braille"
}

# Main script
read -p "Enter a word: " input_word

# Convert the input word to lowercase for simplicity
lowercase_word=$(echo "$input_word" | tr '[:upper:]' '[:lower:]')

# Call the function to convert the word to Braille
result=$(word_to_braille "$lowercase_word")

# Print the result
echo "Braille representation for '$input_word': "
echo "	$result"





