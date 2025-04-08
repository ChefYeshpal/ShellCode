#!/bin/bash


#to generate a random string of a given length
generate_random_string() {
	local length=$1
	tr -dc '[:graph;]' < /dev/urandom | head -c length
}

#to generate a pwd with specified criteria
generate_pwd() {
	local length=$1
	local num_letters=$2
	local num_numbers=$3
	local num_symbols=$4

	local pwd=""

	#generate random string of each category
	local letters=$(generate_random_string $num_letters | tr -dc 'a-zA-z')
    local numbers=$(generate_random_string $num_numbers | tr -dc '0-9')
    local symbols=$(generate_random_string $num_symbols | tr -dc '!@#$%^&*()_-+=<>?')

	#to insert the random strings into the blank pwd
	pwd = "${letters}${numbers}${symbols}"

	#to shuffle the pwd to make the order random
	pwd=$(echo '$pwd" | fold -wi | shuf | tr -d '\n\')

	#if pwd length is less that the desired one, fill in the remaning characters
	while [ ${#password} -lt $length ]; do
        pwd="${pwd}$(generate_random_string 1)"
    done

    # Trim the password to the desired length
    pwd=${pwd:0:$length}

    echo "$pwd"
}

# Generate a password of length 9 with 3 letters, 3 numbers, and 3 symbols
generated_pwd=$(generate_pwd 9 3 3 3)

echo "Generated Password: $generated_pwd"





