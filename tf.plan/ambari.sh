#!/bin/bash

echo "PK Ambari Script" $1 >> /var/log/syslog

if  [ "$#" -ne 1 ];
then echo "usage $0 [start|stop|status]"
exit 15
fi


HOST=$(hostname)
PASSWORD=C0uldN0tC4r3L3ss!

SERVICES="NODEMANAGER DATANODE HBASE_REGIONSERVER LOGSEARCH_LOGFEEDER METRICS_MONITOR PHOENIX_QUERY_SERVER"

function list_service_states(){
        for s in $SERVICES
        do
                echo $s
        done
}

function stop(){
echo "PK Ambari Stop Function" >> var/log/syslog
        for s in $SERVICES
        do
                curl -s --insecure -i -u svc_status:${PASSWORD} -H "X-Requested-By: Ambari" -X PUT -d '{"RequestInfo":{"context":"Auto Stop Component"}, "Body":{"HostRoles":{"state":"INSTALLED"}}}' https://pazsas1004.internal.vanquisbank.co.uk:8443/api/v1/clusters/vcap_prod/hosts/$HOST.internal.vanquisbank.co.uk/host_components/$s

done

echo "wait 5 minutes for shutdown"
sleep 300
echo "stopped services"

}

function start(){
echo "PK Ambari Start Function" >> var/log/syslog

        for s in $SERVICES
        do
                /usr/bin/curl -s --insecure -i -u svc_status:${PASSWORD} -H "X-Requested-By: Ambari" -X PUT -d '{"RequestInfo":{"context":"iAuto Start Component"}, "Body":{"HostRoles":{"state":"STARTED"}}}' https://pazsas1004.internal.vanquisbank.co.uk:8443/api/v1/clusters/vcap_prod/hosts/$HOST.internal.vanquisbank.co.uk/host_components/$s
done
}



#list_service_states
#stop_services
#start_services
#service_status
$1

