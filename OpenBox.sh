#!/bin/sh
echo -ne '\033c\033]0;OpenBox\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/OpenBox.x86_64" "$@"
