#  use the image anywhere
#  in the project to build the image

FROM node:20-alpine

# Set the working directory
WORKDIR /src

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./


# Install dependencies
RUN npm install --production

# Copy the rest of the application code
COPY . .
# Expose the port the app runs on
EXPOSE 3000


# Start the application
CMD ["node", "src/index.js"]  