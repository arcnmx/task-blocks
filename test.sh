#!/bin/bash
set -eu

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

touch "$TASKRC"
task config rc.confirmation=no uda.blocks.type string
task config rc.confirmation=no uda.blocks.label Blocks

task_() {
	echo '> task' "$@" >&2
	command task "$@"
}

task_ add task1
task_ add task2 blocks:task1
assert '[[ $(task +BLOCKING count) -eq 1 ]]'

task_ add task3
task_ task3 modify blocks:task1
assert '[[ $(task +BLOCKING count) -eq 2 ]]'
assert '[[ $(task +BLOCKED count) -eq 1 ]]'

assert '! task_ task3 modify blocks:task4'
