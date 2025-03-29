# Use official Node.js runtime as base image
FROM node:18-alpine

# Set working directory in container
WORKDIR /app

# Copy package.json and package-lock.json (if it exists)
COPY package*.json ./

# Install dependencies
RUN npm install
COPY . .

# Copy the application code


# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["node", "patient-service.js"]