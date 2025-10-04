# Use official Node 16 image as the base image
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json first
COPY package*.json ./

# Install dependencies 
RUN npm install --production

# Copy the entire project into the container
COPY . .

# Expose the application port
EXPOSE 3000

# Set the container start command
CMD ["node", "app.js"]
