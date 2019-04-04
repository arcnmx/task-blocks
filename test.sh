#!/bin/bash
set -xeu

__TASK_DATA_DIR=$(mktemp -d)

trap 'rm -rf "$__TASK_DATA_DIR"' EXIT;

export TASKDATA="$__TASK_DATA_DIR"
export TASKRC="$TASKDATA/taskrc"
make -e install

touch "$TASKRC"
task config rc.confirmation=no uda.blocks.type string
task config rc.confirmation=no uda.blocks.label Blocks

task add task1
task add task2 blocks:task1
task add task3
task task3 modify blocks:task1
task task3 modify blocks:task4 && (echo "Expected failure" >&2 && exit 1)

# TODO: compare this against expected attributes
task export
