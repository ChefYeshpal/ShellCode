#!/bin/bash
date created: 1 april 2024

modifications:
01042024 created and converted code from .py to .sh







# Function to generate a random number within a range
generate_random_number() {
    min=$1
    max=$2
    echo $(( RANDOM % (max - min + 1 ) + min ))
}

# Generate random values for a, b, c, d
minvalue=1
maxvalue=100
a=$(generate_random_number $minvalue $maxvalue)
b=$(generate_random_number $minvalue $maxvalue)
c=$(generate_random_number $minvalue $maxvalue)
d=$(generate_random_number $minvalue $maxvalue)

# Function to perform random operations
perform_random_operations() {
    a=$1
    b=$2
    c=$3
    d=$4

    operations=('+' '-' '*' '/')

    a_operation=${operations[$RANDOM % ${#operations[@]}]}
    b_operation=${operations[$RANDOM % ${#operations[@]}]}
    c_operation=${operations[$RANDOM % ${#operations[@]}]}
    d_operation=${operations[$RANDOM % ${#operations[@]}]}

    expression="$a $a_operation $b $b_operation $c $c_operation $d"
    echo "Performing operations: $expression"

    result=$(echo "$expression" | bc -l)
    echo $result
}

result=$(perform_random_operations $a $b $c $d)

# Ask the user the question
while true; do
    read -p "What is your answer? " usrans

    # Check if the answer is within 0.01 of the correct result
    if [ $(echo "$usrans - $result < 0.01" | bc) -eq 1 ]; then
        echo "Your answer is indeed correct"
        echo $result
        break
    else
        echo "Incorrect value, try again."
    fi
done

