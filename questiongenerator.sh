#! /bin/bash

# Function to generate a random number within a range
generate_random_number() {
    min=$1
    max=$2
    echo $(( RANDOM % (max - min + 1 ) + min ))
}

# Function to generate random arithmetic symbol
generate_random_symbol() {
    symbols=( '+' '-' '*' '/' )
    size=${#symbols[@]}
    index=$(($RANDOM % $size))
    echo ${symbols[$index]}
   # echo ${symbols[$RANDOM % ${#symbols[@]}]}
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

m=$(generate_random_symbol)
n=$(generate_random_symbol)
p=$(generate_random_symbol)
q=$(generate_random_symbol)

echo $m $n $p $q "----123"
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



