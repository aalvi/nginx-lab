#!/usr/bin/env bash
# Checks that each host routes to the right app and unknown hosts do not.
set -uo pipefail

URL=http://127.0.0.1:8080/
fail=0

check() { # name, host, expected body substring
  local body
  body=$(curl -s --max-time 5 -H "Host: $2" "$URL")
  if grep -q "$3" <<<"$body"; then echo "PASS $1"; else echo "FAIL $1: got: $body"; fail=1; fi
}

check "app1.localhost -> app1" app1.localhost "Hostname: app1---"
check "app2.localhost -> app2" app2.localhost "hello from app2---"

code=$(curl -s --max-time 5 -o /dev/null -w '%{http_code}' -H "Host: nope.localhost" "$URL")
if [ "$code" = 404 ]; then echo "PASS unknown host -> 404"; else echo "FAIL unknown host: got $code"; fail=1; fi

URL=http://127.0.0.1:8082/

check "app3.localhost -> app3" app3.localhost "Hostname: app3-"
check "app4.localhost -> app4" app4.localhost "hello from app4"

code=$(curl -s --max-time 5 -o /dev/null -w '%{http_code}' -H "Host: nope.localhost" "$URL")
if [ "$code" = 404 ]; then echo "PASS gateway unknown host -> 404"; else echo "FAIL gateway unknown host: got $code"; fail=1; fi

exit $fail
