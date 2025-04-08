#!/bin/bash

# Function to check if a word is a palindrome
is_palindrome() {
    # Get the input word
    local original_input=$1
    local word=$1
    
    # Convert to lowercase to make the check case-insensitive
    word=$(echo "$word" | tr '[:upper:]' '[:lower:]')
    
    # Remove non-alphanumeric characters
    cleaned_word=$(echo "$word" | tr -cd '[:alnum:]')
    
    # Get the reversed word
    local reversed=""
    local length=${#cleaned_word}
    
    for (( i=$length-1; i>=0; i-- )); do
        reversed="$reversed${cleaned_word:$i:1}"
    done
    
    # Compare the original and reversed words
    if [ "$cleaned_word" = "$reversed" ]; then
        echo "\"$original_input\" is a palindrome!"
        echo "When we remove the spaces and punctuation, it will read the same forward and backward."
        echo "Forward: $cleaned_word"
        echo "Backward: $reversed"
    else
        echo "\"$original_input\" is not a palindrome."
        echo "It doesn't read the same forward and backward."
        echo "Forward: $cleaned_word"
        echo "Backward: $reversed"
    fi
}

# Welcome message
echo "=== Palindrome Checker ==="
echo "Palindrome: A word or phrase reads the same forward and backward."
echo "Examples: 'radar', 'madam', 'racecar', etc"
echo

# Ask for user input
echo "Please enter a word or phrase to check:"
read user_input

# Check if input is empty and figure out how to put in a loop
if [ -z "$user_input" ]; then
    echo "No input provided. Please try again."
    exit 1
fi

# Call the palindrome function with user input
is_palindrome "$user_input"
