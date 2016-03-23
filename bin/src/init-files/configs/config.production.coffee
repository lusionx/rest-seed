
redis =
  host: '192.168.4.104'
  port: 6379
  namespace: 'restmg'

conf =
  service:
    name: 'rest mongo'
    version: '0.0.1'
    port: 8101

  redis: redis

module.exports = conf
