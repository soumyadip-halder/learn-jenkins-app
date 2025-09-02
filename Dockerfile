FROM mcr.microsoft.com/playwright:v1.55.0-noble
RUN apt-get update && apt-get install python3 python3-pip -y
RUN export npm_config_python="$(which python3)"
RUN npm install -g netlify-cli@20.1.1 serve