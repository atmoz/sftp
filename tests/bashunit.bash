#!/usr/bin/env bash

########################################################################
# GLOBALS
########################################################################

verbose=2

bashunit_passed=0
bashunit_failed=0
bashunit_skipped=0

########################################################################
# ASSERT FUNCTIONS
########################################################################

# Assert that a given expression evaluates to true.
#
# $1: Expression
assert() {
    if test $* ; then _passed ; else _failed "$*" true ; fi
}

# Assert that a given output string is equal to an expected string.
#
# $1: Output
# $2: Expected
assertEqual() {
    echo $1 | grep -E "^$2$" > /dev/null
    if [ $? -eq 0 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that a given output string is not equal to an expected string.
#
# $1: Output
# $2: Expected
assertNotEqual() {
    echo $1 | grep -E "^$2$" > /dev/null
    if [ $? -ne 0 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that a given output string starts with an expected string.
#
# $1: Output
# $2: Expected
assertStartsWith() {
    echo $1 | grep -E "^$2" > /dev/null
    if [ $? -eq 0 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that the last command's return code is equal to an expected integer.
#
# $1: Output
# $2: Expected
# $?: Provided
assertReturn() {
    local code=$?
    if [ $code -eq $2 ] ; then _passed ; else _failed "$code" "$2" ; fi
}

# Assert that the last command's return code is not equal to an expected integer.
#
# $1: Output
# $2: Expected
# $?: Provided
assertNotReturn() {
    local code=$?
    if [ $code -ne $2 ] ; then _passed ; else _failed "$code" "$2" ; fi
}

# Assert that a given integer is greater than an expected integer.
#
# $1: Output
# $2: Expected
assertGreaterThan() {
    if [ $1 -gt $2 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that a given integer is greater than or equal to an expected integer.
#
# $1: Output
# $2: Expected
assertAtLeast() {
    if [ $1 -ge $2 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that a given integer is less than an expected integer.
#
# $1: Output
# $2: Expected
assertLessThan() {
    if [ $1 -lt $2 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Assert that a given integer is less than or equal to an expected integer.
#
# $1: Output
# $2: Expected
assertAtMost() {
    if [ $1 -le $2 ] ; then _passed ; else _failed "$1" "$2" ; fi
}

# Skip the current test case.
#
skip() {
    _skipped
}

_failed() {
    bashunit_failed=$((bashunit_failed+1))

    local tc=${FUNCNAME[2]}
    local line=${BASH_LINENO[1]}
    if [ $verbose -ge 2 ] ; then
        echo -e "\033[37;1m$tc\033[0m:$line:\033[31mFailed\033[0m"
    fi
    if [ $verbose -eq 3 ] ; then
        echo -e "\033[31mExpected\033[0m: $2"
        echo -e "\033[31mProvided\033[0m: $1"
    fi
}

_passed() {
    bashunit_passed=$((bashunit_passed+1))

    local tc=${FUNCNAME[2]}
    local line=${BASH_LINENO[1]}
    if [ $verbose -ge 2 ] ; then
        echo -e "\033[37;1m$tc\033[0m:$line:\033[32mPassed\033[0m"
    fi
}

_skipped() {
    bashunit_skipped=$((bashunit_skipped+1))

    local tc=${FUNCNAME[2]}
    local line=${BASH_LINENO[1]}
    if [ $verbose -ge 2 ] ; then
        echo -e "\033[37;1m$tc\033[0m:$line:\033[33mSkipped\033[0m"
    fi
}

########################################################################
# RUN
########################################################################

usage() {
    echo "Usage: <testscript> [options...]"
    echo
    echo "Options:"
    echo "  -v, --verbose  Print exptected and provided values"
    echo "  -s, --summary  Only print summary omitting individual test results"
    echo "  -q, --quiet    Do not print anything to standard output"
    echo "  -h, --help     Show usage screen"
}

runTests() {
    local test_pattern="test[a-zA-Z0-9_]\+"
    local testcases=$(grep "^ *\(function \)*$test_pattern *\\(\\)" $0 | \
        grep -o $test_pattern)

    if [ ! "${testcases[*]}" ] ; then
        usage
        exit 0
    fi

    for tc in $testcases ; do $tc ; done

    if [ $verbose -ge 1 ] ; then
        echo "Done. $bashunit_passed passed." \
             "$bashunit_failed failed." \
             "$bashunit_skipped skipped."
    fi
    exit $bashunit_failed
}

# Arguments
while [ $# -gt 0 ]; do
    arg=$1; shift
    case $arg in
        "-v"|"--verbose") verbose=3;;
        "-s"|"--summary") verbose=1;;
        "-q"|"--quiet")   verbose=0;;
        "-h"|"--help")    usage; exit 0;;
        *) shift;;
    esac
done

runTests
