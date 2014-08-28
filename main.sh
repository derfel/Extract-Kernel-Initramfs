
####
# main invocation of this script
####
[ -z $SOURCED ] && \
function main()
{
    local opt= mode=query output= image=
    local imgo= tmpfile= offsets=
    local imgfile=

    while getopts :qxdo: opt; do
        case "$opt" in
            q)
                mode=query
                ;;
            x)
                mode=cpio
                ;;
            d)
                mode=extract
                ;;
            o)
                [ -z $OPTARG ] && show_help
                output=$OPTARG
                ;;
            *)
                show_help
                ;;
        esac
    done

    ## get kernel image
    shift $((OPTIND-1))
    image=$1
    imgo="$PWD/$(basename "$image")"

    ## verify parameters
    [ -z "$image" ] && show_help
    [ "$mode" = "extract" ] && \
        output=${output:-$imgo.root} ||
        output=${output:-$imgo.cpio}

    ## verify output doesn't exist
    if [ -e "$output" -a "$mode" != "query" ]; then
        echo_error "The output path '$output' exists."
        echo_error "Please remove '$output' by executing: "
        builtin echo "      rm -fr '$output'" >&2
        exit 1
    fi

    ## a header.
    echo "Extract Kernel Initramfs (eki) v$VERSION"
    echo "Based on http://tinyurl.com/nclkczx and " \
         "http://tinyurl.com/49aos4h"
    echo "Source available at" \
         "https://github.com/jotaki/Extract-Kernel-Initramfs"
    echo "============================="
    echo "Bootstrapping..."
    tmpfile=$(xmktemp kernel)
    [ $? -eq 0 ] || exit 1

    imgfile=$(xmktemp initramfs)
    if [ $? -ne 0 ]; then
        rm -rf -- "$tmpfile"
        exit 1
    fi
    echo "Bootstrapping complete"

    ## "decompress" kernel image (really extracts it)
    uncompress_kernel "$image" > "$tmpfile"
    [ $? -eq 0 ] || cleantemp "$tmpfile" "$imgfile"

    ## find potential archive offsets
    offsets=$(detect_compression "$tmpfile")
    [ $? -eq 0 ] || cleantemp "$tmpfile" "$imgfile"

    ## attempt to open/verify archive
    find_archive "$tmpfile" "$offsets" "$imgfile"
    [ $? -eq 0 ] || cleantemp "$tmpfile" "$imgfile"

    echo_debug "Inspecting mode..."
    case "$mode" in
        query)
            echo_debug "  > Querying archive"
            cpio -t < "$imgfile" | less
            echo_debug "  > Finished"
            ;;
        cpio)
            echo_debug "  > Copying file '$imgfile' to '$output'"
            cp -af "$imgfile" "$output"
            echo_debug "  > Finished"
            ;;
        extract)
            if [ -f "$output" ]; then
                echo_error "Invalid usage, expected directory at '$output'"
                break;
            fi

            echo_debug "Creating directory '$output'"
            mkdir -p "$output"

            echo_debug "Changing directory to '$output'"
            cd "$output" 2>/dev/null >&2

            echo_debug "Extracting '$imgfile' to '$output'"
            cpio --quiet -i \
                --make-directories \
                --preserve-modification-time \
                --no-absolute-filenames 2>/dev/null >&2 \
                < "$imgfile"

            echo_debug "Image file extracted"
            echo_debug "Changing directory to '$OLDPWD'"
            cd - 2>/dev/null >&2
            ;;
        *)
            echo "Not sure what to do in this mode."
            echo "Mode provided: '$mode'"
            ;;
    esac

    ## inform the user where to find the archive/root
    [ "$mode" != "query" ] && echo "Resulting output available in '$output'"

    ## Keep files?
    if [ -z "$KEEP_FILES" ]; then
        cleantemp "$tmpfile" "$imgfile"
    else
        echo "You have enabled KEEP_FILES"
        echo "Left over files at:"
        echo "  > $tmpfile"
        echo "  > $imgfile"
    fi
}

# source protect
[ -z $SOURCED ] && main $@
