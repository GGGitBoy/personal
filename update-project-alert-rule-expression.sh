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
rm -rf generated-*

kubectl get projectalertrules.management.cattle.io -A -o json |  jq '[.items |.[] | select(.spec.metricRule!=null and .spec.metricRule.expression!=null)]' >> generated-1-project-metric-alert.json
total=`cat generated-1-project-metric-alert.json | jq length`

echo "INFO: Need to update $total alert rules"

sed 's/name=~\\"^k8s_.\*\\",image!=\\"\\"/container_name!=\\"\\"/g' generated-1-project-metric-alert.json >> generated-2-updated-project-metric-alert.json

echo '#!/bin/sh' >> generated-3-apply-updated-project-alert.sh
chmod +x generated-3-apply-updated-project-alert.sh

cat generated-2-updated-project-metric-alert.json | jq '[.[] | .metadata.namespace  + "###" + .metadata.name + "###" + .spec.metricRule.expression] | .[]' | awk -F### '{print "kubectl patch projectalertrules.management.cattle.io -n " $1 "\"" " " $2 " --type=merge --patch " "'\''"  "{\"spec\":{\"metricRule\":{\"expression\":  " "\"" $3 "}}}" "'\''" }' >> generated-3-apply-updated-project-alert.sh

echo "INFO: Running script"
./generated-3-apply-updated-project-alert.sh

echo "INFO: Success"