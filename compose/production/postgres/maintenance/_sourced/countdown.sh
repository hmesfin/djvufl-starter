#!/usr/bin/env bash


countdown() {
    # A simple countdown. Source: https://superuser.com/a/611582
    local seconds="${1}"
    local d=$(($(date +%s) + seconds))
    while [ "$d" -ge "$(date +%s)" ]; do
        local current_time
        current_time=$(date +%s)
        echo -ne "$(date -u --date @$((d - current_time)) +%H:%M:%S)\r";
        sleep 0.1
    done
}
