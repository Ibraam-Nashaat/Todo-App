# Use small Node image
FROM node:24-alpine3.21

# Create app directory
WORKDIR /app

# Install app dependencies
COPY package*.json ./
RUN npm install --production

# Bundle app source
COPY . .

# App listens on port 4000
EXPOSE 4000

# Start the app (in prod mode)
CMD ["node", "index.js"]
