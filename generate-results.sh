#!/bin/bash -e

# This script will substitute the benchmark results into the HTML page.
# Note: editing HTML with sed may look strange, but at least we avoid using node.js and npm, and that's good.

# This is needed on Mac OS. Do `brew install coreutils`.
if [[ "$(uname)" == "Darwin" ]]; then
  if ! command -v gsed >/dev/null 2>&1
  then
    echo "On macOS, please install GNU sed through homebrew."
    exit 1
  else
    shopt -s expand_aliases
    alias sed='gsed'
  fi
fi

(
    sed '/^const data = \[$/q' index.html

    FIRST=1
    LANG="" ls -1 */results*/*.json | while read -r file
    do
        [ "${FIRST}" = "0" ] && echo -n ','
        jq --compact-output ". += {\"source\": \"${file}\"}" "${file}" || echo "Error in $file" >&2
        FIRST=0
    done

    echo ']; // end of data'
    sed '0,/^\]; \/\/ end of data$/d' index.html

) > index.html.new

mv index.html index.html.bak
mv index.html.new index.html
