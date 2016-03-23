
redis =
  host: '192.168.4.104'
  port: 6379
  namespace: 'restseed'

conf =
  service:
    name: 'rest seed'
    version: '0.0.1'
    port: 8100

  redis: redis

module.exports = conf
