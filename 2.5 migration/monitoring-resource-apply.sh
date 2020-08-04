#!/bin/sh
for f in `cat dev-prometheusrules-2.json | jq -r 'keys[]'` ; do
  cat dev-prometheusrules-2.json | jq '.['$f']' >> prometheusrules-$f.json
  kubectl apply -f prometheusrules-$f.json 
done

for f in `cat dev-servicemonitors-2.json | jq -r 'keys[]'` ; do
  cat dev-servicemonitors-2.json | jq '.['$f']' >> servicemonitors-$f.json
  kubectl apply -f servicemonitors-$f.json 
done

rm -f prometheusrules-*.json
rm -f servicemonitors-*.json

echo "INFO: Success"