#!/usr/bin/env bash

set -e

declare -r  cluster1=$1
declare -r  cluster2=$3

CLUSTER1_CONFIG=$2
CLUSTER2_CONFIG=$4

declare -a k8s_kind_list="$(<k8s_kind_list.txt)"

export KUBECONFIG=${CLUSTER1_CONFIG}
for i in ${k8s_kind_list}; do
  declare -a cluster1_kind_${i}="$(kubectl explain ${i} 2> /dev/null | awk '/VERSION/{ rc = 1; print $2 }; END { exit !rc }' || echo "unknown-kind")"
done

export KUBECONFIG=${CLUSTER2_CONFIG}
for i in ${k8s_kind_list}; do
  declare -a cluster2_kind_${i}="$(kubectl explain ${i} 2> /dev/null | awk '/VERSION/{ rc = 1; print $2 }; END { exit !rc }' || echo "unknown-kind")"
done

for kind in ${!cluster1_kind_*} ${!cluster2_kind_*}; do
  declare server="${kind//"_kind_"*}"
  All_kinds+="${!server} ${kind//*"_kind_"/} ${!kind}\n"
done

echo -e "${All_kinds}" | sed '/^$/d' | pr -2 -t -s | column -t



