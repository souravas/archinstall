#!/usr/bin/env zsh
# Custom functions for zsh
# This file contains all custom functions that can be sourced by .zshrc

# Compression functions
compress() {
    tar -czf "${1%/}.tar.gz" "${1%/}"
}

# Media duration calculation function
media_duration() {
    local sum_s=0 dur time hh mm ss total_s H M S
    for f in *; do
        [[ -f $f ]] || continue
        dur=$(mediainfo --Inform="General;%Duration/String3%" "$f")
        time=${dur%%.*}
        if [[ $time =~ ^[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
            printf "%-8s  %s\n" "$time" "$f"
            IFS=: read hh mm ss <<< "$time"
            (( sum_s += 10#$hh*3600 + 10#$mm*60 + 10#$ss ))
        fi
    done
    H=$(( sum_s/3600 )); M=$(( (sum_s%3600)/60 )); S=$(( sum_s%60 ))
    printf "\\nTotal duration: %02d:%02d:%02d\\n" $H $M $S
}

# File manipulation functions
add_prefix() {
    local prefix=$1
    for f in *; do
        [[ -f "$f" ]] && mv -- "$f" "${prefix}${f}"
    done
}

prefix_folders() {
    local count=1
    for dir in */; do
        [[ -d "$dir" ]] || continue
        prefix=$(printf "%02d - " "$count")
        for file in "$dir"*; do
            [[ -f "$file" ]] || continue
            base=$(basename "$file")
            mv -- "$file" "${dir}${prefix}${base}"
        done
        ((count++))
    done
}

unprefix_folders() {
    for dir in */; do
        [[ -d "$dir" ]] || continue
        for src in "$dir"*; do
            [[ -f "$src" ]] || continue
            filename="${src##*/}"
            case "$filename" in
                [0-9][0-9]\ -\ *)
                    newname="${filename:5}"
                    echo "Renaming: '$filename' -> '$newname'"
                    mv -- "$src" "${dir}${newname}"
                    ;;
                *) echo "Skipping: '$filename'";;
            esac
        done
    done
}

# Append suffix to filenames
# Usage: add_suffix "_SUFFIX"
add_suffix() {
    suffix=$1
    if [ -z "$suffix" ]; then
        printf 'Usage: add_suffix "_SUFFIX"\\n' >&2
        return 1
    fi
    set -- *
    if [ "$#" -eq 1 ] && [ "$1" = "*" ]; then
        echo "No files to rename."
        return 0
    fi
    for file; do
        [ -f "$file" ] || continue
        mv -- "$file" "${file}${suffix}"
    done
}

# Remove characters from beginning of filenames
remove_characters() {
    local num="$1"
    if [[ -z "$num" || ! "$num" =~ ^[0-9]+$ ]]; then
        echo "Usage: remove_characters <num_chars_to_remove>"
        return 1
    fi
    set -- *
    if [ "$#" -eq 1 ] && [ "$1" = "*" ]; then
        echo "No files to rename."
        return 0
    fi
    for file; do
        [[ -f "$file" ]] || continue
        filename="$file"
        newname="${filename:$num}"
        [[ -n "$newname" && "$newname" != "$filename" ]] || continue
        echo "Renaming: '$filename' -> '$newname'"
        mv -- "$file" "$newname"
    done
}

# Copy folder structure without files
copy_folder_structure() {
    mkdir -p _folders
    for dir in */; do
        [[ -d "$dir" ]] || continue
        mkdir -p "_folders/${dir%/}"
    done
}
