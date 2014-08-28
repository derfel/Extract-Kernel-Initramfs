####
# Supported signatures
#####

# Signatures
ALL_SIGS='gzip bzip2 lzma none'
GZIP_SIG='\x1F\x8B\x08'
BZIP_SIG='\x31\x41\x59\x26\x53\x59'
LZMA_SIG='\x5D\x00\x..\xFF\xFF\xFF\xFF\xFF\xFF'
CPIO_SIG='070701'

####
# Wrapper to use appropriate decompression tool
# exports SIGNATURE, COMMAND, CSCHEME and SIG_ADJ (signature offset adjustment)
# environment variables. use: use_signature --zap to unset.
####
function use_signature()
{
    echo_debug "Function: use_signature()"

    SIG_ADJ=1
    case $1 in
        gzip)
            SIGNATURE=$GZIP_SIG
            COMMAND='gunzip -9fq'
            CSCHEME=gzip
            ;;
        bzip2)
            SIGNATURE=$BZIP_SIG
            COMMAND='bunzip2 -q'
            CSCHEME=bzip2
            SIG_ADJ=-3
            ;;
        lzma)
            SIGNATURE=$LZMA_SIG
            COMMAND='unlzma -q'
            CSCHEME=lzma
            ;;
        none)
            SIGNATURE=$CPIO_SIG
            COMMAND=cat
            CSCHEME=none
            ;;

        --zap)
            unset SIGNATURE COMMAND CSCHEME SIG_ADJ
            return 0
            ;;

        *)
            echo_error "Invalid usage of use_signature()"
            exit 1
    esac

    export SIGNATURE COMMAND CSCHEME SIG_ADJ
}

