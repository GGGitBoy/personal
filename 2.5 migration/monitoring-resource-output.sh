#!/bin/sh

echo "INFO: Environment Prechecking"

if command -v jq >/dev/null 2>&1; then 
  echo >&1 'INFO: Command jq existed' 
else 
  echo >&2 "ERROR: Require jq to run this script, but it isn't installed, download from https://github.com/stedolan/jq/releases"
fi

if command -v kubectl >/dev/null 2>&1; then 
  echo >&1 'INFO: Command kubectl existed' 
else 
  echo >&2 "ERROR: Require kubectl to run this script, but it isn't installed, read install document here https://kubernetes.io/zh/docs/tasks/tools/install-kubectl/"
fi

if [ $KUBECONFIG ];then
	echo "INFO: KUBECONFIG = $KUBECONFIG"
else
	echo "ERROR: Environment KUBECONFIG isn't exist"
fi

echo "INFO: Generating script"

rm -f dev-*.json

kubectl get prometheusrules.monitoring.coreos.com -A -o json |  jq '[.items |.[] | select(.metadata.namespace=="cattle-prometheus")]' >> dev-prometheusrules-1.json

totalprometheusrules=`cat dev-prometheusrules-1.json | jq length`
echo "INFO: Need to update $totalprometheusrules prometheusrules"


kubectl get servicemonitors.monitoring.coreos.com -A -o json |  jq '[.items |.[] | select(.metadata.namespace=="cattle-prometheus")]' >> dev-servicemonitors-1.json

totalservicemonitors=`cat dev-servicemonitors-1.json | jq length`
echo "INFO: Need to update $totalservicemonitors servicemonitors"

sed 's/cattle-prometheus/cattle-monitoring-system/g' dev-prometheusrules-1.json >> dev-prometheusrules-2.json
sed 's/cattle-prometheus/cattle-monitoring-system/g' dev-servicemonitors-1.json >> dev-servicemonitors-2.json

echo "INFO: Success"
