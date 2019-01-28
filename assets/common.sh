#!/usr/bin/env bash

set -euo pipefail

shopt -s expand_aliases

exec 3>&1
exec 1>&2

__LOG_COLOR_DEBUG__=$'\e[92m'
__LOG_COLOR_INFO__=$'\e[93m'
__LOG_COLOR_ERROR__=$'\e[91m'
__LOG_COLOR_RESET__=$'\e[39m'

###
# Uppercases a string.  If the bash version is 4 or greater, the ${var^^} builtin will be used; otherwise, awk is used.
#
# Environment:
#   BASH_VERSION {string} Provided from bash.
#
# Echos:
#   The string in uppercase.
#
# Returns:
#   0
##
function uppercase() {
  local _var="$1"
  if [ "${BASH_VERSION:0:1}" = "4" ]; then
    echo "${_var^^}"
  else
    echo "${_var}" | awk '{print toupper($0)}'
  fi
}

###
# Prints log messages to stdout and a log file.
#
# Environment:
#   LOGGER_FILE {file} The file to send output to as well.  Defaults to '/dev/null'.
#   LOGGER_DATE_FORMAT {string} The date format to use for timestamps.  Defaults to '%Y-%m-%d %H:%M:%S %Z'.
#
# Returns:
#   0
##
function log() {
  local LEVEL=$(uppercase $1)
  local color=__LOG_COLOR_${LEVEL}__
  local reset=__LOG_COLOR_RESET__

  shift

  echo -e "[${!color}${LEVEL}${!reset}] ${@}" >&2

}

alias debug='log debug'
alias info='log info'
alias error='log error'

# Grab payload from stdin

payload=payload.json
cat > $payload

ca_cert=concourse_ca.crt
cat $payload | jq -rj '.source.ca_cert // ""' > $ca_cert

insecure=$( cat $payload | jq -r '.source.insecure' )
target=$( cat $payload | jq -r '.source.target // "'"${ATC_EXTERNAL_URL}"'"' )
username=$( cat $payload | jq -r '.source.username // ""' )
password=$( cat $payload | jq -r '.source.password // ""' )
team=$( cat $payload | jq -r '.source.team // ""' )
pipeline=$( cat $payload | jq -r '.source.pipeline' )
job=$( cat $payload | jq -r '.source.job' )
status=$( cat $payload | jq -r '.source.status // ""' )

# Validation
if [[ -z $target ]]; then
  error "Missing required source option: target" >&2
  exit 1
fi

if [[ ${insecure} == 'true' && -s "${ca_cert}" ]]; then
  error "Cannot specify both insecure and ca_cert" >&2
  exit 1
fi

if [[ -z $pipeline ]]; then
  error "Missing required source option: pipeline" >&2
  exit 1
fi

if [[ -z $job ]]; then
  error "Missing required source option: pipeline" >&2
  exit 1
fi

# Assemble options

ssl_options=''
if [[ ${insecure} == true ]]; then
  debug "Skipping SSL validation"
  ssl_options="-k"
elif [[ -s "${ca_cert}" ]]; then
  debug "Adding CA cert"
  ssl_options="--ca-cert ${ca_cert}"
fi

auth_options=''
if [[ -n $username ]]; then
  debug "Adding auth"
  auth_options="-u $username -p $(printf '%q' "${password:-}")"
fi
if [[ -n $team ]]; then
  debug "Adding team"
  auth_options="$auth_options -n $team"
fi

# Log in

info "Logging in..."
fly -t "$target" login $ssl_options -c "$target" $auth_options

info "Syncing..."
fly -t "$target" sync
