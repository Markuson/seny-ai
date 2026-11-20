#!/usr/bin/env bash
# Seny: the last commits, for /seny:help ("last done"). Read-only, always exits 0.
top=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "not a git repository"; exit 0; }
cd "$top" && git log --oneline -6 --date=relative --format='%h %s (%cr)' 2>/dev/null || echo "no commits yet"
exit 0
