#!/bin/sh

echo $0 "Databases check. Wainting for pg_isready -U $POSTGRES_USER"

wait_for_db() {
  sleep 2
  until pg_isready -U "$POSTGRES_USER"; do
    >&2 echo $0 "Postgres is unavailable - sleeping for 3 seconds."
    sleep 2
  done

  echo $0 "Postgres is up - executing command"

  sh /checks/check-user.sh "check-cytomine" "$CYTOMINE_USER" "$CYTOMINE_PASSWORD" "$CYTOMINE_DB"
  sh /checks/check-user.sh "check-appengine" "$APPENGINE_USER" "$APPENGINE_PASSWORD" "$APPENGINE_DB"
  sh /checks/check-user.sh "check-monitoring" "$MONITORING_USER" "$MONITORING_PASSWORD" "$MONITORING_DB"
}

# This will be executed in background as we need the database server to be ready.
wait_for_db &

# executing next entrypoint, even if there are running background tasks. It will allow Postgres to start.
exec "$@"