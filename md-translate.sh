#!/bin/bash
# Copyright (c) 2024 Ho Kim (ho.kim@ulagbulag.io). All rights reserved.
# Use of this source code is governed by MIT license that can be
# found in the LICENSE file.

# Prehibit errors
set -e -o pipefail

###########################################################
#   Configuration                                         #
###########################################################

# Configure default environment variables
OPENAI_API_URL_DEFAULT="https://api.openai.com/v1/chat/completions"
PROMPT_PATH_DEFAULT="$(pwd)/prompt.md"
TEMPLATE_PATH_DEFAULT="$(pwd)/template.json"

# Configure environment variables
OPENAI_API_URL="${OPENAI_API_URL:-$OPENAI_API_URL_DEFAULT}"
PROMPT_PATH="${PROMPT_PATH:-$PROMPT_PATH_DEFAULT}"
TEMPLATE_PATH="${TEMPLATE_PATH:-$TEMPLATE_PATH_DEFAULT}"

###########################################################
#   Check Environment Variables                           #
###########################################################

function _assert_file() {
    local key="$1"

    # try to parse from cache
    if [ ! -f "${!key}" ]; then
        echo "No such file (${key}): ${!key}" >&2
        exit 1
    fi
}

function _assert_key() {
    local key="$1"

    # try to parse from cache
    if [ -z "${!key+x}" ]; then
        echo "Environment variable \"${key}\" not set" >&2
        exit 1
    fi
}

_assert_file 'PROMPT_PATH'
_assert_file 'TEMPLATE_PATH'

_assert_key 'OPENAI_API_KEY'

###########################################################
#   Main Function                                         #
###########################################################

function main() {
    input_file="$(mktemp)"
    output_file="$(mktemp)"

    # Read stdin
    cat - >"${input_file}"

    # Call translator
    cat "${TEMPLATE_PATH}" |
        jq -e |
        jq -e "( .messages // [] | . ) += [{\"role\": \"user\", \"content\": \$input}]" --rawfile input "${PROMPT_PATH}" |
        jq -e "( .messages // [] | . ) += [{\"role\": \"user\", \"content\": \$input}]" --rawfile input "${input_file}" |
        curl -s -X POST "${OPENAI_API_URL}" \
            -H "Authorization: Bearer ${OPENAI_API_KEY}" \
            -H "Content-Type: application/json" \
            -d @- >"${output_file}"

    # Parse the outputs
    if cat "${output_file}" | jq -e '.error.message' >/dev/null; then
        echo "$(cat "${output_file}" | jq -e -r '.error.message')" >&2
        exit 1
    fi
    exec cat "${output_file}" | jq -e -r '.choices[0].message.content'
}

# Execute main function
main "$@"
