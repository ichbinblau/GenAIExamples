#!/bin/bash
# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

set -e
IMAGE_REPO=${IMAGE_REPO:-"opea"}
IMAGE_TAG=${IMAGE_TAG:-"latest"}
echo "REGISTRY=IMAGE_REPO=${IMAGE_REPO}"
echo "TAG=IMAGE_TAG=${IMAGE_TAG}"
export REGISTRY=${IMAGE_REPO}
export TAG=${IMAGE_TAG}

WORKPATH="$PWD"
LOG_PATH="$WORKPATH/tests"
ip_address=$(hostname -I | awk '{print $1}')

function build_docker_images() {
    cd $WORKPATH/docker_image_build
    rm -fr GenAIComps 
    git clone https://github.com/opea-project/GenAIComps.git && cd GenAIComps && git checkout "${opea_branch:-"main"}"

    # a patch to resolve parameter error on Intel model
    sed -i 's/relationship_properties=\[\"description\"\]/relationship_properties=False/g' comps/dataprep/neo4j/langchain/prepare_doc_neo4j.py
    sed -i 's/node_properties=\[\"description\"\]/node_properties=False/g' comps/dataprep/neo4j/langchain/prepare_doc_neo4j.py
    echo "json-repair" >> comps/dataprep/neo4j/langchain/requirements.txt 
    cd ..

    echo "Build all the images with --no-cache, check docker_image_build.log for details..."
    service_list="chatqna chatqna-ui dataprep-neo4j embedding-tei retriever-neo4j reranking-tei llm-tgi nginx"
    docker compose -f build.yaml build ${service_list} --no-cache > ${LOG_PATH}/docker_image_build.log

    docker pull ghcr.io/huggingface/tgi-gaudi:2.0.5
    docker pull ghcr.io/huggingface/text-embeddings-inference:sha-e4201f4-intel-cpu

    docker images && sleep 1s
}

function start_services() {
    cd $WORKPATH/docker_compose/intel/cpu/xeon/

    export http_proxy=${http_proxy}
    export https_proxy=${https_proxy}
    export no_proxy=${no_proxy}
    export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
    export RERANK_MODEL_ID="BAAI/bge-reranker-base"
    export LLM_MODEL_ID="Intel/neural-chat-7b-v3-3"
    export TEI_EMBEDDING_ENDPOINT="http://${ip_address}:6006"
    export TEI_RERANKING_ENDPOINT="http://${ip_address}:8808"
    export TGI_LLM_ENDPOINT="http://${ip_address}:9009"
    export NEO4J_URI=bolt://${host_ip}:7687
    export NEO4J_USERNAME=neo4j
    export NEO4J_PASSWORD=password
    export HUGGINGFACEHUB_API_TOKEN=${HUGGINGFACEHUB_API_TOKEN}
    export MEGA_SERVICE_HOST_IP=${ip_address}
    export EMBEDDING_SERVICE_HOST_IP=${ip_address}
    export RETRIEVER_SERVICE_HOST_IP=${ip_address}
    export RERANK_SERVICE_HOST_IP=${ip_address}
    export LLM_SERVICE_HOST_IP=${ip_address}
    export BACKEND_SERVICE_ENDPOINT="http://${ip_address}:8888/v1/chatqna"
    export DATAPREP_SERVICE_ENDPOINT="http://${ip_address}:6007/v1/dataprep"
    export DATAPREP_GET_FILE_ENDPOINT="http://${ip_address}:6007/v1/dataprep/get_file"
    export DATAPREP_DELETE_FILE_ENDPOINT="http://${ip_address}:6007/v1/dataprep/delete_file"
    export FRONTEND_SERVICE_IP=${host_ip}
    export FRONTEND_SERVICE_PORT=5173
    export BACKEND_SERVICE_NAME=chatqna
    export BACKEND_SERVICE_IP=${host_ip}
    export BACKEND_SERVICE_PORT=8888
    export NGINX_PORT=80

    sed -i "s/backend_address/$ip_address/g" $WORKPATH/ui/svelte/.env

    # Start Docker Containers
    docker compose -f compose_graphrag.yaml up -d > ${LOG_PATH}/start_services_with_compose.log
    n=0
    until [[ "$n" -ge 500 ]]; do
        docker logs tgi-service > ${LOG_PATH}/tgi_service_start.log
        if grep -q Connected ${LOG_PATH}/tgi_service_start.log; then
            break
        fi
        sleep 1s
        n=$((n+1))
    done
}

function stop_docker() {
    cd $WORKPATH/docker_compose/intel/cpu/xeon/
    docker compose stop && docker compose rm -f
}

function main() {

    stop_docker
    if [[ "$IMAGE_REPO" == "opea" ]]; then build_docker_images; fi
    start_time=$(date +%s)
    start_services
    end_time=$(date +%s)
    duration=$((end_time-start_time))
    echo "Mega service start duration is $duration s" && sleep 1s
}

main
