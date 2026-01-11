# Simple Makefile for linux-utils

PREFIX ?= /usr/local/bin
SHELL := /bin/bash

# Gather scripts across category folders
SCRIPTS := $(shell find networking system-monitoring file-management security docker-utils setup -type f -name '*.sh')

.PHONY: help install lint format list

help:
	@echo "Targets:"
	@echo "  install  - Copy scripts to $(PREFIX)"
	@echo "  lint     - Run shellcheck on scripts (if available)"
	@echo "  format   - Run shfmt on scripts (if available)"
	@echo "  list     - List all scripts"

list:
	@for f in $(SCRIPTS); do echo $$f; done

install:
	@mkdir -p $(PREFIX)
	@for f in $(SCRIPTS); do \
		name=$$(basename $$f); \
		install -m 0755 $$f $(PREFIX)/$$name; \
		echo "Installed: $(PREFIX)/$$name"; \
	done

lint:
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck $(SCRIPTS); \
	else \
		echo "shellcheck not found; skipping"; \
	fi

format:
	@if command -v shfmt >/dev/null 2>&1; then \
		shfmt -w networking system-monitoring file-management security docker-utils setup; \
	else \
		echo "shfmt not found; skipping"; \
	fi
