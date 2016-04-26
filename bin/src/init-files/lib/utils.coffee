_         = require 'lodash'
async     = require 'async'
rest      = require 'rest-seed'
conf      = require '../configs'

cache = null
cacheDelay = () ->
  return if cache
  cache = redis.createClient conf.redis.port, conf.redis.host

utils =
  redis: (m, key, arr...) ->
    cacheDelay()
    arr.unshift conf.redis.namespace + '::' + key
    fn = cache[m]
    fn.apply cache, arr

  getCache: (key, cb) ->
    cacheDelay()
    namespace = conf.redis.namespace
    k = namespace + '::' + key
    cache.get k, (err, data) ->
      return cb err if err
      cb null, JSON.parse data

  getCacheKeys: (key, cb) ->
    cacheDelay()
    namespace = conf.redis.namespace
    k = namespace + '::' + key
    cache.keys k, (err, data) ->
      return cb err if err
      cb null, _.map data, (e) -> e[namespace.length+2..]

  setCache: (key, val, life=60, cb=null) ->
    cacheDelay()
    namespace = conf.redis.namespace
    k = namespace + '::' + key
    v = JSON.stringify val
    cache.set k, v, (err) ->
      return cb? err if err
      cache.expire k, +life or 1, (err) ->
        cb? err if err
        cb? null

module.exports = _.extend utils, rest.utils
