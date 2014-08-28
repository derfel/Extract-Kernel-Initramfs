####
# find cpio archive relative of position
####
function find_archive()
{
    local image="$1" archive=($2) total=${#archive[@]} a=0
    local pos= output="$3" sig=${archive[0]} found=
    
    echo_debug "Function: find_archive('$1', $2, '$3')"
    echo "Detected $((total - 1)) potential archives"

    echo_debug "Using signature '$sig'"
    use_signature "$sig" # shouldn't fail.

    for((a = 1; a < $total; a++)) {
        echo "Trying #$a"

        pos=$((${archive[$a]} + SIG_ADJ))
        echo_debug "  reverse_offset=$pos command=$COMMAND"
        echo_debug "  \$ tail -c +$pos \"$image\" | $COMMAND" \
                   "2>/dev/null > \"$output\""

        # tail bytes and pass through to $COMMAND
        tail -c +$pos "$image" | $COMMAND 2>/dev/null > "$output"
        if [ $? -ne 0 ]; then
            cat /dev/null > "$output"
            echo_debug "Try #$a of $((total - 1)) for '$CSCHEME' failed."
            echo "  > ... Failed"
            continue;
        else
            echo "  > ... Success"
            found=1; break
        fi
    }
    use_signature --zap

    if [ -z "$found" ]; then
        echo_error "All archive extraction attempts failed. Aborting"
        return 1;
    fi
}
