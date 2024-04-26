RED='\033[0;31m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORM=$(tput sgr0)

declare -r  cluster1=$1
declare -r  cluster2=$3

CLUSTER1_CONFIG=$2
CLUSTER2_CONFIG=$4

export KUBECONFIG=${CLUSTER1_CONFIG}
declare -a masternodes_c1=($(kubectl get nodes 2> /dev/null | awk '/master/{ rc = 1; print $1 }; END { exit !rc }'))

if ((${#masternodes_c1[@]})); then
    #declare -A cluster1_master_info=([cpu]=4 [ephemeral-storage]=100724788Ki [hugepages-1Gi]=0 [hugepages-2Mi]=0 [OSImage]=Ubuntu20.04.2LTS [OperatingSystem]=linux [Architecture]=amd64 [ContainerRuntimeVersion]=docker [KubeletVersion]=v1.20.6 [Kube-ProxyVersion]=v1.20.6)
    myvalue=$(kubectl describe node ${masternodes_c1[0]} 2> /dev/null | awk -F ':'  '/Capacity/ { for(i=1; i<=4; i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}} /System Info/  { for(i=0; i<=3; i++) {getline}; for(i=0;i<=5;i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}}')
    declare -A cluster1_master_info=()
    while IFS="=" read -r a b; do
        cluster1_master_info["$a"]="$b"
    done < <(
        echo ${myvalue} |
            tr ' ' '\n' |
            tr -d '[]'
    )   
fi

declare -a workernodes_c1=($(kubectl get nodes 2> /dev/null | awk '/worker/{ rc = 1; print $1 }; END { exit !rc }'))

if ((${#workernodes_c1[@]})); then
    #declare -A cluster1_worker_info=([cpu]=4 [ephemeral-storage]=100724788Ki [hugepages-1Gi]=0 [hugepages-2Mi]=0 [OSImage]=Ubuntu20.04.2LTS [OperatingSystem]=linux [Architecture]=amd64 [ContainerRuntimeVersion]=docker [KubeletVersion]=v1.20.6 [Kube-ProxyVersion]=v1.20.6)
    myvalue=$(kubectl describe node ${workernodes_c1[0]} 2> /dev/null | awk -F ':'  '/Capacity/ { for(i=1; i<=4; i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}} /System Info/  { for(i=0; i<=3; i++) {getline}; for(i=0;i<=5;i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}}')
    declare -A cluster1_worker_info=()
    while IFS="=" read -r a b; do
        cluster1_worker_info["$a"]="$b"
    done < <(
        echo ${myvalue} |
            tr ' ' '\n' |
            tr -d '[]'
    )   
fi


export KUBECONFIG=${CLUSTER2_CONFIG}
declare -a masternodes_c2=($(kubectl get nodes 2> /dev/null | awk '/master/{ rc = 1; print $1 }; END { exit !rc }'))

if ((${#masternodes_c2[@]})); then
    #declare -A cluster1_master_info=([cpu]=4 [ephemeral-storage]=100724788Ki [hugepages-1Gi]=0 [hugepages-2Mi]=0 [OSImage]=Ubuntu20.04.2LTS [OperatingSystem]=linux [Architecture]=amd64 [ContainerRuntimeVersion]=docker [KubeletVersion]=v1.20.6 [Kube-ProxyVersion]=v1.20.6)
    myvalue=$(kubectl describe node ${masternodes_c2[0]} 2> /dev/null | awk -F ':'  '/Capacity/ { for(i=1; i<=4; i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}} /System Info/  { for(i=0; i<=3; i++) {getline}; for(i=0;i<=5;i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}}')
    declare -A cluster2_master_info=()
    while IFS="=" read -r a b; do
        cluster2_master_info["$a"]="$b"
    done < <(
        echo ${myvalue} |
            tr ' ' '\n' |
            tr -d '[]'
    )   
fi

declare -a workernodes_c2=($(kubectl get nodes 2> /dev/null | awk '/worker/{ rc = 1; print $1 }; END { exit !rc }'))

if ((${#workernodes_c2[@]})); then
    #declare -A cluster1_worker_info=([cpu]=4 [ephemeral-storage]=100724788Ki [hugepages-1Gi]=0 [hugepages-2Mi]=0 [OSImage]=Ubuntu20.04.2LTS [OperatingSystem]=linux [Architecture]=amd64 [ContainerRuntimeVersion]=docker [KubeletVersion]=v1.20.6 [Kube-ProxyVersion]=v1.20.6)
    myvalue=$(kubectl describe node ${workernodes_c2[0]} 2> /dev/null | awk -F ':'  '/Capacity/ { for(i=1; i<=4; i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}} /System Info/  { for(i=0; i<=3; i++) {getline}; for(i=0;i<=5;i++) {getline; gsub(/ /, "", $0);  print"["$1"]="$2}}')
    declare -A cluster2_worker_info=()
    while IFS="=" read -r a b; do
        cluster2_worker_info["$a"]="$b"
    done < <(
        echo ${myvalue} |
            tr ' ' '\n' |
            tr -d '[]'
    )   
fi

echo -e "${RED}Comparing ${BOLD}master values${NC}${NORM}"
for i in "${!cluster1_master_info[@]}"
do
    if [ ${cluster1_master_info[$i]} != ${cluster2_master_info[$i]} ]
        then echo "$i values are different ${cluster1_master_info[$i]} - ${cluster2_master_info[$i]} " 
    fi
done


echo -e "${RED}Comparing ${BOLD}worker values${NC}${NORM}"
for i in "${!cluster1_worker_info[@]}"
do
    if [ ${cluster1_worker_info[$i]} != ${cluster2_worker_info[$i]} ]
        then echo "$i values are different ${cluster1_master_info[$i]} - ${cluster2_master_info[$i]} " 
    fi
done
