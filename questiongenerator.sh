#!/bin/bash
#date created: 1 april 2024

#what it does:
#the purpose of this program is to create a question with the parameters of + - * and /, having randomised locations and random numbers between 1 to 100

#this is to help me in improving my ability to do simple calculations faster and more accurately, it's margin of error will be 0.01  or upto 2 decimal places

#modifications:
#01042024 created and converted code from .py to .sh
#02042024 fixed some bugs, re-wrote the entire program due to excessive command not found errors
#


#solved bugs:
#1. not showing question
#2. date: extra operand ‘1’
#Try 'date --help' for more information.
#3. ./questiongenerator.sh: line 4: modifications:: command not found
#4. ./questiongenerator.sh: line 5: 01042024: command not found
#5. ./questiongenerator.sh: line 15: =1: command not found
#6. ./questiongenerator.sh: line 16: =100: command not found
#7. ./questiongenerator.sh: line 15: =1: command not found
#8. ./questiongenerator.sh: line 16: =100: command not found
#9. ./questiongenerator.sh: line 15: =1: command not found
#10. ./questiongenerator.sh: line 16: =100: command not found
#11. ./questiongenerator.sh: line 15: =1: command not found
#12. ./questiongenerator.sh: line 16: =100: command not found
#13. Runtime error (func=(main), adr=6): Divide by zero



#################################################################################################################



#!/bin/bash

# Function to generate a random number within a range
generate_random_number() {
    min=$1
    max=$2
    echo $(( RANDOM % (max - min + 1 ) + min ))
}

# Function to generate random arithmetic symbol
generate_random_symbol() {
    symbols=( '+' '-' '*' '/' )
    echo ${symbols[$RANDOM % ${#symbols[@]}]}
}

# Generate random values for a, b, c, d
minvalue=1
maxvalue=100
a=$(generate_random_number $minvalue $maxvalue)
b=$(generate_random_number $minvalue $maxvalue)
c=$(generate_random_number $minvalue $maxvalue)
d=$(generate_random_number $minvalue $maxvalue)

# Shuffle the arithmetic symbols
symbols=($(generate_random_symbol) $(generate_random_symbol) $(generate_random_symbol))

# Generate the question string
question="$a ${symbols[0]} $b ${symbols[1]} $c ${symbols[2]} $d"

# Calculate the result
result=$(echo "$question" | bc -l)

# Display the question
echo "Question: $question"

# Ask the user for the answer
while true; do
    read -p "What is your answer? " usrans

    # Check if the answer is empty
    if [[ -z "$usrans" ]]; then
        echo "Please provide an answer."
        continue
    fi

    # Check if the answer is within 0.01 of the correct result
    if (( $(echo "$usrans - $result < 0.01" | bc -l) )); then
        echo "Your answer is indeed correct"
        echo "Correct answer: $result"
        break
    else
        echo "Incorrect value, try again."
    fi
done



