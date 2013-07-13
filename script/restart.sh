#!/bin/bash

set -e
cd $(dirname $0)

host=propile
user=matteo

ssh $user@$host <<EOF
	export RAILS_ENV=production
	set -e
	cd propile
	set -x
	cat tmp/pids/server.pid | xargs kill -9 || true
	rails server --daemon
EOF