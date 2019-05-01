#!/bin/bash
set -eu
set -o pipefail

assert() {
	if ! eval "$1"; then
		echo "assertion failed: $1" >&2
		return 1
	fi
}

__TASK_DATA_DIR=$(mktemp -d)

trap 'rm -rf "$__TASK_DATA_DIR"' EXIT;

export TASKDATA="$__TASK_DATA_DIR"
export TASKRC="$TASKDATA/taskrc"
make -e install

task_() {
	echo '> task' "$@" >&2
	command task "$@"
}

touch "$TASKRC"

main() {
	task config rc.confirmation=no uda.blocks.type string
	task config rc.confirmation=no uda.blocked.type string

	task_ add task1
	task_ add task2 blocks:task1
	assert '[[ $(task +BLOCKING count) -eq 1 ]]'

	task_ add task3
	task_ task3 modify blocks:task1
	assert '[[ $(task +BLOCKING count) -eq 2 ]]'
	assert '[[ $(task +BLOCKED count) -eq 1 ]]'

	assert '! task_ task3 modify blocks:task4'

	assert '[[ $(task blocks.any: count) -eq 0 ]]'

	task_ task3 modify blocks:-task1
	task_ task2 modify blocks:-task1
	assert '[[ $(task +BLOCKING count) -eq 0 ]]'
	assert '[[ $(task +BLOCKED count) -eq 0 ]]'

	task_ task1 modify blocked:task2,task3
	assert '[[ $(task +BLOCKING count) -eq 2 ]]'
	assert '[[ $(task +BLOCKED count) -eq 1 ]]'

	task_ task1 modify blocked:-task3
	assert '[[ $(task +BLOCKING count) -eq 1 ]]'
	assert '[[ $(task +BLOCKED count) -eq 1 ]]'

	assert '[[ $(task blocked.any: count) -eq 0 ]]'
}

main 2>&1 | grep -vF " override"
