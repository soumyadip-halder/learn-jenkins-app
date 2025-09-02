FROM mcr.microsoft.com/playwright:v1.55.0-noble
RUN apk update
RUN apk add --no-cache python3 py3-pip
RUN export npm_config_python="$(which python3)"
RUN npm install netlify-cli@20.1.1 serve