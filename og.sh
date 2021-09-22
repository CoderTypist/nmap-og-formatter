#!/bin/bash
# Author: Christian Bargraser

# Description:
#     Format nmap grepable output
# Arguments:
#     - $1: file path
# Outputs:
#     - More readable output
main() {
    assert_args 1 "$#" "Please specify the file to parse"
    file="$1"

    while read -r line ; do
        
        # check to see if the line contains port information
        has_ports "$line"
        
        # if the line contains port information
        if [ "$?" == 1 ] ; then
            # print informtion for each port on a separate line
            pprint_ports "$line"
        else
            echo "$line"
        fi

    done < "$file"
}

# Description:
#     Ensure that a function receives some minimum number of arguments
# Arguments:
#     - $1: number of arguments that the function should receive at minimum
#     - $2: number of arguments that the function actually received ($#)
#     - $3 (optional): error message
# Returns:
#     - n/a, exits the program if insufficient arguments were provided
assert_args() {
    if [ "$#" -lt 2 ] ; then
        echo "assert_args(): Specify number of args to check for"
        exit -1
    fi

    args_needed="$1"
    args_present="$2"

    if [ "$args_present" -lt "$args_needed" ] ; then
        
        # if a custom error message was provided
        if [ "$#" -ge 3 ] ; then
            custom_error_message="$3"
            echo "assert_args(): $custom_error_message"
        else
            echo "assert_args(): Function requires $args_needed argument(s), but only $args_present were provided"
        fi

        exit -1
    fi
}

# Description:
#     check to see if a line contains some word
# Arguments:
#     - $1: line of text to search
#     - $2: word to search for
# Returns:
#     - returns via $?
#     - 0: line did not contain the word
#     - 1: line did contain the word
has_word() {
    assert_args 2 "$#"

    line="$1"
    word="$2"
    
    # if a blank line is returned, the word was not in the line
    # otherwise, the line contains the word
    result="$(echo "$line" | sed -n "/$word/p")"
    
    if [ -z "$result" ] ; then
        return 0
    else
        return 1
    fi
}

# Description:
#     Check to see if the line contains a hosts status
# Arguments:
#     - $1: line of text to search
# Returns:
#     - returns via $?
#     - returns the value returned from has_word()
#     - 0: line did not contain the word "Ports"
#     - 1: line did contain the word "Ports"
has_ports() {
    assert_args 1 "$#"
    line="$1"
    has_word "$line" "Ports"
    return "$?"
}

# Description:
#     Makes port information easier to read
# Arguments:
#     - $1: line to format
# Returns:
#     - n/a
pprint_ports() {
    assert_args 1 "$#"
    line="$1"

    # convert multiple '/' into a single '/'
    line="$(echo "$line" | sed -E 's|/+|/|g')"
    
    # remove everything after the last '/'
    # this works because of greedy matching
    # this remove extra information such as the number of closed ports
    line="$(echo "$line" | sed -E 's|^(.*/).*$|\1|g')"

    port_info="$(echo "$line" | sed -E 's/.*Ports:(.*)/\1/g')"
    
    # store the info for each port in a separate line
    ports=$(echo "$port_info" | awk 'BEGIN{FS=","} { for(i=1;i<=NF;i++) { print($i) } }')

    # format and print the info for each port
    # Why IFS?
    # Without IFS, lines are tokenized at whitespace
    # bash removes the newline character, but we want to keep it for tokenizaiton purposes
    # we can keep by by adding the '$' 
     
    IFS=$'\n'
    for line in $ports; do
        
        # remove the trailing '/'
        line="${line:0:${#line}-1}"

        # extract the port number
        port_num="$(echo "$line" | awk 'BEGIN{FS="/"} {print($1)}')"
        
        # extract port info
        port_info="$(echo "$line" | awk 'BEGIN{FS="/"} {for(i=2;i<=NF;i++){ if(NF!=i){printf("%s, ", $i)}else{printf("%s\n", $i)}}}')"
        
        # output formatted port information
        printf "\t%-6d%s\n" "$port_num" "$port_info" 
    done
}

main "$@"
