#!/bin/sh


function checkout {
    mkdir -p "$BTRDIR" && cd "$BTRDIR" || error

    if test -d "$CLEAN_DIR"
    then
        echo Pulling updates...
        cd "$CLEAN_DIR" && git pull || error
        cd ..
    else
        git clone "$SOURCE_URL" "$CLEAN_DIR" || error
    fi

    if test -d "$BRANCH_DIR"
    then
        cd "$BRANCH_DIR" && git pull || error
        cd ..
    else
        git-new-workdir "$CLEAN_DIR" "$BRANCH_DIR" "$BRANCH" || error
    fi
    echo
}

function report {
    echo "Reporting..."
    cd "$BTRDIR" || error
    echo "Running '$REPORT_COMMAND'"
    local REPORT_ERROR=$(eval "$REPORT_COMMAND" 2>&1) || error $REPORT_ERROR
    exit
}

function build {
    echo "Building..."
    cd "$BTRDIR" || error
    mkdir -p "$BUILD_DIR" || error

    echo "Running '$BUILD_COMMAND'"
    if ! eval "$BUILD_COMMAND" > "$BUILD_REPORT" 2>&1
    then
        SUCCESS=FAILURE
        report <<EOF

btr report for $BUILD

FAILURE: build
COMMAND: $BUILD_COMMAND

$(cat "$BTRDIR/$BUILD_REPORT")

-- 
btr

EOF
    fi
    echo
}

function diffsum {
    cd "$BTRDIR" || error
    local LAST_TEST_REPORT=$(ls ".btr+tests-$BUILD-"* | tail -2 | head -1)
    if test "$TEST_REPORT" != "$LAST_TEST_REPORT"
    then
        local LAST_TESTS_PASSED=$(awk '/^Tests passed/ {print $4}' "$LAST_TEST_REPORT")
        local LAST_TESTS_FAILED=$(awk '/^Tests failed/ {print $4}' "$LAST_TEST_REPORT")
        local TESTS_PASSED=$(awk '/^Tests passed/ {print $4}' "$TEST_REPORT")
        local TESTS_FAILED=$(awk '/^Tests failed/ {print $4}' "$TEST_REPORT")

        local DIFF_TEST_REPORT=$(diff -u $LAST_TEST_REPORT $TEST_REPORT)
        DIFFSUM="+$(grep -c "^+" <<<"$DIFF_TEST_REPORT")/-$(grep -c "^-" <<<"$DIFF_TEST_REPORT")"
    fi
}

function tests {
    echo "Testing..."
    cd "$BTRDIR" || error
    
    echo "Running '$TEST_COMMAND'"
    if ! eval "$TEST_COMMAND" > "$TEST_REPORT" 2>&1
    then
        SUCCESS=FAILURE
    else
        SUCCESS=SUCCESS
        diffsum
    fi
    echo
}

