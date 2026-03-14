#!/bin/bash
cat ~/.librewolf/*/sessionstore-backups/recovery.js 2>/dev/null | grep -o 'http[s]*://[^"]*'
