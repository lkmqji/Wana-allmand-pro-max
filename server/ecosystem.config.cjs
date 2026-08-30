module.exports = {
  apps: [
    {
      name: 'wana-backend',
      script: 'index.js',
      instances: 1, // Single instance for in-memory Socket.io rooms (or use sticky sessions + Redis adapter if clustered)
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      }
    }
  ]
};
