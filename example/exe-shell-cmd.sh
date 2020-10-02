#!/bin/bash 

NETWORK_NAME="macvlan-net-vm-node1"
ZK_SERVERS="zk-c1-n1:2181,zk-c1-n2:2181,zk-c1-n3:2181" 
METADATA_SERVICE_URI="zk+hierarchical://zk-c1-n1:2181,zk-c1-n2:2181,zk-c1-n3:2181/ledger" 
IMAGE="aldrin/bookkeeper"
CMD=""
CMDARGS=""

exeShellCmd() {
	local _CMD=$1
	local _CMD_ARGS=$2
	docker run -it --rm --network $NETWORK_NAME \
		--env ZK_SERVERS="$ZK_SERVERS" \
		--env "console.log(process.env)" $IMAGE bookkeeper shell $_CMD $_CMD_ARGS
}
	#	--env METADATA_SERVICE_URI="$METADATA_SERVICE_URI" \

initNewCluster() {
	exeShellCmd "initnewcluster" 
}

nukeExistingCluster() {
	local _CMD_ARGS=$1	
	exeShellCmd "nukeexistingcluster" "$_CMD_ARGS"
}

#nukeExistingCluster '--zkledgersrootpath /ledgers -f' 
##--instanceid ffc8c135-6688-4613-a187-938c62125b04' 
#initNewCluster

nukeExistingCluster '--zkledgersrootpath /ledgers -f'  &&  initNewCluster
#exeShellCmd bookiesanity

#::END:: 
