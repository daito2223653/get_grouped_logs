# written by daito
## -- get cmd argument function -- ##

## -- get COMPOSE_PROJECT_NAME/COUCHDB_LOG_FILE/TARGET function() -- ##
COMPOSE_PROJECT_NAME="sw360_dev"
# NOTE: couchDB's log is in /usr/local/var/log/couchdb/couch.log (COUCHDB_LOG_FILE). this is changed by daito at docker-images/sw360couchdb/docker-entrypoint~~.sh.
COUCHDB_LOG_FILE="/usr/local/var/log/couchdb/couch.log"
# target default:  couch.log.
TARGET="couch.log"

echo "cmd: sudo docker cp ${COMPOSE_PROJECT_NAME}_sw360couchdb:${COUCHDB_LOG_FILE=} ${TARGET}"
## -- echo info -- ##
# echo "COMPOSE_PROJECT_NAME= , COUCH_LOG...= TARGET....="

sudo docker cp ${COMPOSE_PROJECT_NAME}_sw360couchdb:${COUCHDB_LOG_FILE=} ${TARGET}

## -- error  hundl. -- ##
echo "ok."
