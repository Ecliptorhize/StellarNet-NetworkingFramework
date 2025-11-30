FROM node:18-alpine

WORKDIR /workspace

COPY package*.json ./
COPY bin ./bin
COPY StellarNet ./StellarNet
COPY README.md ./README.md
COPY LICENSE ./LICENSE

RUN npm install --ignore-scripts --omit=dev

CMD ["npm", "pack"]
