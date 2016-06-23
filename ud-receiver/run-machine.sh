# A function to echo in blue color
function blue() {
	es=`tput setaf 4`
	ee=`tput sgr0`
	echo "${es}$1${ee}"
}

if [ "$#" -ne 1 ]; then
    blue "Illegal number of parameters"
	blue "Usage: ./run-machine.sh <machine_number>"
	exit
fi

blue "Removing hugepages"
shm-rm.sh 1>/dev/null 2>/dev/null

export HRD_REGISTRY_IP="10.113.1.47"
export MLX5_SINGLE_THREADED=1
export MLX_QP_ALLOC_TYPE="HUGE"
export MLX_CQ_ALLOC_TYPE="HUGE"

num_threads=7			# Threads per client machine

: ${HRD_REGISTRY_IP:?"Need to set HRD_REGISTRY_IP non-empty"}

blue "Running $num_threads client threads"

sudo LD_LIBRARY_PATH=/usr/local/lib/ -E \
	numactl --cpunodebind=0 --membind=0 ./main \
	--num-threads $num_threads \
	--dual-port 1 \
	--is-client 1 \
	--machine-id $1 \
	--size 32 \
	--postlist 16 \

#debug: run --num-threads 1 --dual-port 1 --is-client 1 --machine-id 0 --size 32 --window 128
