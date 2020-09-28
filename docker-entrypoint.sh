#!/bin/bash

CMD=$1

# Create broker configuration file if it doesn't exist 
BK_SERVER_CONF="${BK_HOME}/conf/bk_server.conf" 
if [[ ! -f "${BK_SERVER_CONF}" ]]; then
	cat <<-EOF > $BK_SERVER_CONF
		bookiePort=$BOOKIE_PORT
		useHostNameAsBookieID=$USE_HOST_NAME_AS_BOOKIE_ID
		useShortHostName=$USE_SHORT_HOST_NAME
		bookieDeathWatchInterval=$BOOKIE_DEATH_WATCH_INTERVAL
		extraServerComponents=$EXTRA_SERVER_COMPONENTS
		httpServerEnabled=$HTTP_SERVER_ENABLED
		httpServerPort=$HTTP_SERVER_PORT
		httpServerClass=$HTTP_SERVER_CLASS
		journalDirectories=$JOURNAL_DIRECTORIES
		ledgerStorageClass=$LEDGER_STORAGE_CLASS
		ledgerDirectories=$LEDGER_DIRECTORIES
		metadataServiceUri=$METADATA_SERVICE_URI
		zkServers=$ZK_SERVERS
		zkTimeout=$ZK_TIMEOUT
		zkEnableSecurity=$ZK_ENABLE_SECURITY
		storageserver.grpc.port=$STORAGESERVER_GRPC_PORT
		dlog.bkcEnsembleSize=$DLOG_BKC_ENSEMBLE_SIZE
		dlog.bkcWriteQuorumSize=$DLOG_BKC_WRITE_QUORUM_SIZE
		dlog.bkcAckQuorumSize=$DLOG_BKC_ACK_QUORUM_SIZE
		storage.range.store.dirs=$STORAGE_RANGE_STORE_DIRS
		storage.serve.readonly.tables=$STORAGE_SERVE_READONLY_TABLES
		storage.cluster.controller.schedule.interval.ms=$STORAGE_CLUSTER_CONTROLLER_SCHEDULE_INTERVAL_MS 
		EOF
fi

isZkServerReachable()
{
	local zkServer=$1
	if (( $(echo 'srvr' | nc $zkServer 2181 > /dev/null 2>&1; echo $?) )); then
		echo 0
	else
		echo 1
	fi
} 

source $BK_SERVER_CONF

# If the command is bookkeeper then check if zookeeper nodes are reachable & if not then abort.  
if [[ "$CMD" == "bookkeeper" ]]; then
	reachable=0
	serverList=${zkServers//,/ }
	echo "Checking if Zookeeper servers reachable..."
	for chkCount in $(seq 1 5); do
		for server in $serverList; do
			echo "  * Checking Zookeeper server: $server..."
			if (( $(isZkServerReachable $server) )); then
				reachable=1
				break
			fi
			echo "      $server not reachable."
		done
		if (( $reachable == 1 )); then
			break
		else
			echo "Zookeeper servers are not reachable. Checking again in 3 seconds..."
			sleep 3 
		fi
	done
	if (( $reachable == 1 )); then
		exec "$@"
	else
		echo "Zookeeper servers are not reachable. Tried 3 times.  Aborting..."
		exit 1
	fi
else
	exec "$@"
fi


#::END::
