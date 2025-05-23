#!/usr/bin/env bash

# Copyright (C) 2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
export TAG="1.2"
export LOGFLAG=true
export no_proxy=chatqna-ui-server,chatqna-backend-server,dataprep-redis-service,tei-embedding-service,retriever,tei-reranking-service,tgi-service,vllm-service,$no_proxy
export host_ip="10.239.241.56"
export EMBEDDING_MODEL_ID="BAAI/bge-base-en-v1.5"
export RERANK_MODEL_ID="BAAI/bge-reranker-base"
export LLM_MODEL_ID="deepseek-ai/DeepSeek-R1-Distill-Qwen-7B"
#export TEI_EMBEDDING_ENDPOINT="http://${host_ip}:8090"
export INDEX_NAME="rag-redis"
#export MEGA_SERVICE_HOST_IP=${host_ip}
#export RETRIEVER_SERVICE_HOST_IP=${host_ip}
export BACKEND_SERVICE_ENDPOINT="/v1/chatqna"
export DATAPREP_SERVICE_ENDPOINT="/v1/dataprep/ingest"
export DATAPREP_GET_FILE_ENDPOINT="/v1/dataprep/get"
export DATAPREP_DELETE_FILE_ENDPOINT="/v1/dataprep/delete"
#export FRONTEND_SERVICE_IP=${host_ip}
#export FRONTEND_SERVICE_PORT=5173
#export BACKEND_SERVICE_NAME=chatqna
#export BACKEND_SERVICE_IP=${host_ip}
#export BACKEND_SERVICE_PORT=8888
export NGINX_PORT=8000
export HUGGINGFACEHUB_API_TOKEN="your token"
