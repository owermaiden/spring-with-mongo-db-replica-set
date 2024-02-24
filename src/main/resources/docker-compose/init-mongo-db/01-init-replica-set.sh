#!/bin/bash

PRIMARY_INSTANCE_IP=172.16.238.10
SECONDARY_01_INSTANCE_IP=172.16.238.11
SECONDARY_02_INSTANCE_IP=172.16.238.12

echo "########### Waiting for primary ###########"
until mongosh --host ${PRIMARY_INSTANCE_IP}:27017  -u root -p example --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping  ###########"
    sleep 5
  done


echo "########### Waiting for replica 01  ###########"
until mongosh --host ${SECONDARY_01_INSTANCE_IP}:27018 -u root -p example --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping  ###########"
    sleep 5
  done


echo "########### Waiting for replica 02  ###########"
until mongosh --host ${SECONDARY_02_INSTANCE_IP}:27019 -u root -p example --eval "printjson(db.runCommand({ serverStatus: 1}).ok)"
  do
    echo "########### Sleeping  ###########"
    sleep 5
  done

echo "########### All replicas are ready!!!  ###########"

echo "########### Setting up cluster config  ###########"

echo "########### Getting replica set status  ###########"
mongosh --host ${PRIMARY_INSTANCE_IP} -u root -p example <<EOF
rs.status()
EOF
echo "########### Initiating replica set ###########"
mongosh --host ${PRIMARY_INSTANCE_IP} -u root -p example  <<EOF
rs.initiate(
   {
      _id: "rs0",
      version: 1,
      members: [
         { _id: 0, host: "mongo1:27017" },
         { _id: 1, host: "mongo2:27018" },
         { _id: 2, host: "mongo3:27019" }
      ]
   }
)
EOF

echo "########### Getting replica set status again  ###########"
mongosh --host ${PRIMARY_INSTANCE_IP} -u root -p example   <<EOF
rs.status()
EOF

echo "########### Stopping TEMP instance  ###########"
mongod --shutdown


