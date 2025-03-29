# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (if it exists)
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3001

# Command to run the application
CMD ["node", "appointment-service.js"]

