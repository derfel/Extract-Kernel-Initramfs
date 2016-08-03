# uncompress kernel
function uncompress_kernel()
{
    local image=$1 scheme=gzip pos= size= newsize=
    echo_debug "Function: uncompress_kernel('$1')"

    pos=$(find_position $GZIP_SIG "$image" | cut -f1 -d:)
    size=$(stat -c '%s' "$image")

    echo_debug "Size: ${size}bytes, Rewind Offset: ${pos}bytes"
    if [ -z "$pos" -o -z "$size" ]; then
        echo_error "Compressed kernel image not found"
        return 1
    fi

    newsize=$((size - pos))
    echo "Extracting compressed kernel image from file"
    echo "  > kernel image: $image"
    echo "  > kernel image size: $size"
    echo "  > compression scheme: $scheme"
    echo "  > position: $pos"
    echo "  > size after strip: $newsize"

    ## BUG?!?
    tail -c $newsize "$image" | gunzip -q9f - 2>/dev/null
    if [ $? -ne 0 ]; then
        echo_debug "gunzip failed?"
        return 1
    fi

    return 0
}

# detect compression
function detect_compression()
{
    local scheme= image=$1 pos= found=

    echo_debug "Function: detect_compression('$1')"
    echo "Detecting compression type"

    for scheme in $ALL_SIGS; do
        use_signature $scheme
        echo_debug "Checking for '$scheme'"

        # search for signature
        pos=$(find_position $SIGNATURE "$image" | cut -f1 -d:)
        pos=$(builtin echo -n $pos | sed 's/\n/ /g') # yuck
        [ $? -eq 0 ] || continue

        if [ -z "$pos" ]; then
            # shouldn't get here.
            echo_error "Something went wrong on signature check '$scheme'"
            return 1
        fi

        echo_debug "Found '$scheme'; breaking loop. ( $pos )"
        found=1; break
    done

    echo_debug "  > Command: $COMMAND"
    echo_debug "  > Compression: $CSCHEME"
    echo_debug "  > Adjustment: $SIG_ADJ"

    # no archive was found.
    if [ -z $found ]; then
        echo_error "No archive was found in file '$image'"
        echo_error "Please verify that you supplied the correct kernel image."
        return 1
    fi

    # "return" the compression scheme and position(s)
    builtin echo -n "$CSCHEME $pos"
}
