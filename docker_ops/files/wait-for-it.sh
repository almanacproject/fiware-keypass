#!/bin/sh
#   Use this script to test if a given TCP host/port are available
# The MIT License (MIT)
# Copyright (c) 2016 Giles Hall
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

cmdname=$(basename "$0")

echoerr() {
    if [ "$QUIET" -ne 1 ]; then
        printf "%s\n" "$*" 1>&2;
    fi
}

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname host:port [-s] [-t timeout] [-- command args]
    -s                          Only execute subcommand if the test succeeds
    -q                          Don't output any status messages
    -t TIMEOUT 
                                Timeout in seconds, zero for no timeout
    -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
    exit 1
}

wait_for()
{
    if [ "$TIMEOUT" -gt 0 ]; then
        echoerr "$cmdname: waiting $TIMEOUT seconds for $HOST:$PORT"
    else
        echoerr "$cmdname: waiting for $HOST:$PORT without a timeout"
    fi
    start_ts=$(date +%s)
    while :
    do
        (printf "" | nc "$HOST" "$PORT") >/dev/null 2>&1
        result=$?
        if [ "$result" -eq 0 ]; then
            end_ts=$(date +%s)
            echoerr "$cmdname: $HOST:$PORT is available after $((end_ts - start_ts)) seconds"
            break
        fi
        sleep 1
    done
    return $result
}

wait_for_wrapper()
{
    # In order to support SIGINT during timeout: http://unix.stackexchange.com/a/57692
    if [ "$QUIET" -eq 1 ]; then
        timeout -t "$TIMEOUT" "$0" -q -child "$HOST":"$PORT" -t "$TIMEOUT" &
    else
        timeout -t "$TIMEOUT" "$0" --child "$HOST":"$PORT" -t "$TIMEOUT" &
    fi
    PID=$!
    trap 'kill -INT -$PID' INT
    wait $PID
    RESULT=$?
    if [ $RESULT -ne 0 ]; then
        echoerr "$cmdname: timeout occurred after waiting $TIMEOUT seconds for $HOST:$PORT"
    fi
    return $RESULT
}

TIMEOUT=15
STRICT=0
CHILD=0
QUIET=0
# process arguments

printf "%s\n" "$*"

while [ "$#" -gt 0 ]
do
    case "$1" in
        *:* )
        HOST=$(printf "%s" "$1"| awk -v FS=":" '{ print $1 }')
        PORT=$(printf "%s" "$1"| awk -v FS=":" '{ print $2 }')
        shift 1
        ;;
        --child)
        CHILD=1
        shift 1
        ;;
        -q)
        QUIET=1
        shift 1
        ;;
        -s)
        STRICT=1
        shift 1
        ;;
        -t)
        TIMEOUT="$2"
        if [ "$TIMEOUT" = "" ]; then
            break;
        fi
        shift 2
        ;;
        --)
        shift 1
        break
        ;;
        --help)
        usage
        ;;
        *)
        echoerr "Unknown argument: $1"
        usage
        ;;
    esac
done

if [ "$HOST" = "" -o "$PORT" = "" ]; then
    echoerr "Error: you need to provide a host and port to test."
    usage
fi

if [ "$CHILD" -gt 0 ]; then
    wait_for
    RESULT=$?
    exit $RESULT
else
    if [ "$TIMEOUT" -gt 0 ]; then
        wait_for_wrapper
        RESULT=$?
    else
        wait_for
        RESULT=$?
    fi
fi

if [ "$*" != "" ]; then
    if [ $RESULT -ne 0 -a $STRICT -eq 1 ]; then
        echoerr "$cmdname: strict mode, refusing to execute subprocess"
        exit $RESULT
    fi
    exec "$@"
else
    exit $RESULT
fi
