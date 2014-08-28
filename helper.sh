####
# outputs help
####
function show_help()
{
cat <<EOF
    Available options:

      -q        -- query archive (cpio -t)
      -x        -- extract archive (cpio)
      -d        -- extract archive (directory root)
      -o <path> -- output filename / directory
      -h        -- this output

    Example usage:
      eki -d -o /tmp/initramfs /boot/vmlinuz.bin
EOF
    exit 0
}

####
# Helper functions
####

# echo only on debug
function echo_debug() { [ -z $DEBUG ] || builtin echo "-D- $@" >&2; }

# echo an error
function echo_error() { builtin echo "-E- $@" >&2; }

# overlay standard echo
function echo() { builtin echo "-I- $@" >&2; }

# use grep to search for compression signature
function find_position() { grep -Pabo $1 "$2" 2>/dev/null; }

# temp file
function xmktemp()
{
    local tmpfile=

    echo_debug "Creating tempfile ($1)"
    tmpfile=$(mktemp -q --tmpdir eki-$1-XXXXX)
    if [ ! -e "$tmpfile" ]; then
        echo_debug "Failed to create '$tmpfile'"
        echo "Bootstrap failed"
        return 1
    fi
    echo_debug "Successfully created '$tmpfile'"

    builtin echo -n "$tmpfile"
}

# clean tempfile
function cleantemp()
{
    if [ -z "$KEEP_FILES" ]; then
        echo_debug "Removing '$1' and '$2'"
        rm -rf -- "$1" "$2"
    else
        echo "You have enabled KEEP_FILES"
        echo "Left over files available at:"
        echo "  > $1"
        echo "  > $2"
    fi
    exit ${3:-1}
}
