# Local GraphRAG Setup on Intel Xeon
The guide is for setting up a local graph RAG based ChatQnA. **The main difference between Local Graph RAG and Global Graph RAG lies in the scope and method of information retrieval and summarization:**
1. **Local Graph RAG**  
  Focus: Targets specific entities or closely related groups of entities.
  Method: Uses entities as entry points to build context. When a query is made, it retrieves the nearest entities and uses graph traversal to gather relevant information.
  Best For: Detailed, targeted queries about specific entities or small groups of entities1.
2. **Global Graph RAG**    
  Focus: Addresses broader, thematic questions that span across the entire dataset.
  Method: Utilizes pre-computed summaries of each entity community. When a query is made, it asks the question to every community and combines these partial responses into a comprehensive answer.
  Best For: Broad, thematic questions that require an overview or synthesis of large datasets21.    
In essence, Local Graph RAG is more suitable for precise, entity-focused queries, while Global Graph RAG excels at providing comprehensive answers to broad, thematic questions.

## Quick Start Deployment Steps:
Our current evaluation runs `Intel/neural-chat-7b-v3-3` on Intel Xeon. Plz also do leave 150G+ storage space in the system for the model. 

1. Checkout GraphRAG source code
  ```bash
  git clone https://github.com/ichbinblau/GenAIExamples/
  cd GenAIExamples/
  git checkout graphrag
  cd ChatQnA/
  ```
2. Set up the environment variables.
  ```bash
   export HUGGINGFACEHUB_API_TOKEN=${your_hf_token} # needed for TGI/TEI models as we use llama3 model
   ```
   If you are in a proxy environment, also set the proxy-related environment variables:
   ```bash
   export host_ip=${your_hostname IP} #local IP, i.e "192.168.1.1"
   export http_proxy="Your_HTTP_Proxy"
   export https_proxy="Your_HTTPs_Proxy"
   export no_proxy=$no_proxy,${host_ip} #important to add {host_ip} for containers communication
   ```
3. Run startup script to build images and start services.
  ```bash
  ./local_graphrag_script.sh # it would take a few mins to download model for the first time. 
  ```
4. Consume the GraphRAG Service.
   To chat with retrieved information, you need to upload a file using `Dataprep` service.
   ```bash
   curl -x "" -X POST \
    -H "Content-Type: multipart/form-data" \
    -F "files=@./docker_compose/intel/cpu/xeon/file-curie.txt" \
    http://localhost:6004/v1/dataprep
   ```
   Consume the graphrag service.
   ```bash
   curl -x "" http://localhost:8888/v1/chatqna \
   -H "Content-Type: application/json" \
   -d "{\"messages\": [{\"role\": \"user\",\"content\": \"Who is Marie Curie and what are her scientific achievements?\"}]}"
   ```
## Tear down the services
```bash
cd docker_compose/intel/cpu/xeon/
export host_ip=${your_hostname IP} #local IP, i.e "192.168.1.1"
source ./set_env_gr.sh
export HUGGINGFACEHUB_API_TOKEN=${your_hf_token}
docker compose down
```
