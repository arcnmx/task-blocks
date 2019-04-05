all:
	@echo nothing to do >&2

ifndef TASKDATA
install:
	$(error TASKDATA not set)
else
install:
	install -Dm0755 task-blocks "$(TASKDATA)/hooks/on-exit.task-blocks"
endif

.PHONY: install
