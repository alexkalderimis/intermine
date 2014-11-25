#!/bin/bash

set -e

export ANT_OPTS='-server'

FAILURES=$PWD/failures.list

ant_test () {
    if [ -d "$1/main" ]; then
      echo RUNNING ant -f "$1/main/build.xml" clean
      ant -f "$1/main/build.xml" clean
      echo RUNNING ant -f "$1/main/build.xml"
      ant -f "$1/main/build.xml"
    fi
    echo RUNNING ant -f "$1/test/build.xml" clean
    ant -f "$1/test/build.xml" clean
    echo RUNNING ant -f "$1/test/build.xml"
    ant -f "$1/test/build.xml" -Ddont.minify=true 2>&1 \
        | tee >(grep FAILED >> $FAILURES)
}

if [ "$TEST_SUITE" = "model" ]; then
    ant_test 'intermine/model'
elif [ "$TEST_SUITE" = "objectstore" ]; then
    ant_test 'intermine/objectstore'
elif [ "$TEST_SUITE" = "integrate" ]; then
    ant_test 'intermine/integrate'
elif [ "$TEST_SUITE" = "pathquery" ]; then
    ant_test 'intermine/pathquery'
elif [ "$TEST_SUITE" = "api" ]; then
    ant_test 'intermine/api'
elif [ "$TEST_SUITE" = "web" ]; then
    ant_test 'intermine/web'
elif [ "$TEST_SUITE" = "bio" ]; then
    ant_test 'bio/core'
elif [ "$TEST_SUITE" = "checkstyle" ]; then
    ant -f 'intermine/all/build.xml' checkstyle \
        | tee >(grep FAILED >> failures.list)
elif [ "$TEST_SUITE" = "selenium" ]; then
    . config/run-selenium-tests.sh
fi

cat $FAILURES
test ! -s $FAILURES