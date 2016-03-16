fs        = require 'fs'
path      = require 'path'
_         = require 'lodash'

# 随机字符串字典
RAND_STR_DICT =
  noraml: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  strong: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()_+<>{}|\=-`~'

cache = null
cacheDelay = () ->
  return if cache
  cache = redis.createClient conf.redis.port, conf.redis.host

utils =

  # 根据设置的路径，获取对象
  getModules: (_path) ->
    modules = {}
    for file in utils.readdir(_path, ['coffee', 'js'])
      moduleName = utils.file2Module file
      modules[moduleName] = require "#{_path}/#{file}"

    modules


  ###
  # 判断给定ip是否是白名单里的ip地址
  ###
  isPrivateIp: (ip, whiteList) ->
    ip in whiteList

  # 真实的连接请求端ip
  remoteIp: (req) ->
    req.connection && req.connection.remoteAddress or
    req.socket && req.socket.remoteAddress or
    (
      req.connection && req.connection.socket &&
      req.connection.socket.remoteAddress
    )

  ###
  # 获取客户端真实ip地址
  ###
  clientIp: (req) ->
    (
      req.headers['x-forwarded-for'] or
      utils.remoteIp(req)
    ).split(',')[0]

  ###
  # 获取可信任的真实ip
  ###
  realIp: (req, proxyIps = []) ->
    remoteIp = utils.remoteIp(req)
    return remoteIp unless remoteIp in proxyIps
    return req.headers['x-real-ip'] or remoteIp

  # 读取录下的所有模块，之后返回数组
  # 对象的key是模块的名称，值是模块本身
  # params
  #   dir 要加载的目录
  #   exts 要加载的模块文件后缀，多个可以是数组, 默认为 coffee
  #   excludes 要排除的文件, 默认排除 index
  readdir: (dir, exts = 'coffee', excludes = 'index') ->
    exts = [exts] if _.isString exts
    excludes = [excludes] if _.isString excludes
    _.chain(fs.readdirSync(dir))
      .map((x) -> x.split('.'))
      .filter((x) -> x[1] in exts and x[0] not in excludes)
      .map((x) -> x[0])
      .value()

  # 文件名称到moduleName的转换
  # example, twe cases
  # case1. filename => filename
  # case2. file-name => fileName
  file2Module: (file) ->
    file.replace /(\-\w)/g, (m) -> m[1].toUpperCase()

  # 获取id，从 params 或者 hooks 中
  getId: (req, _id, _obj) ->
    obj = if _obj then req.hooks[_obj] else req.params
    utils.intval obj[_id]

  ucwords: (value) ->
    return value unless _.isString(value)
    "#{value[0].toUpperCase()}#{value.substring(1)}"

  # 将字符串里的换行，制表符替换为普通空格
  nt2space: (val) ->
    return val unless _.isString val
    # 将换行、tab、多个空格等字符换成一个空格
    val.replace(/(\\[ntrfv]|\s)+/g, ' ').trim()

  # 获取accessToken
  getToken: (req) ->
    req.headers['x-auth-token'] or
      req.params.access_token or
      req.params.accessToken


  # 将字符串转换为数组
  str2arr: _.memoize((qstr, spliter, maxLen) ->
    return unless qstr
    return unless _.isString qstr
    return unless qstr = qstr.trim()
    arr = qstr.split(spliter)
    return arr unless maxLen
    arr[0...maxLen]
  , (qstr, spliter, maxLen) -> "#{qstr}_#{spliter}_#{maxLen}")


  # 生成随机字符串
  # @params
  #   len int.unsigned 生成的随机串的长度
  #   type enum('noraml', 'strong') 随即串的强度, defaultValue is noraml
  randStr: (len, type = 'normal') ->
    dict = RAND_STR_DICT[type] or RAND_STR_DICT.noraml
    len = 3 if utils.intval(len) < 1
    length = dict.length
    (dict[Math.floor((Math.random() * length))] for i in [1..len]).join('')

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

  request: (par, cb) ->
    fn = (callback) ->
      request par, (err, resp, body) ->
        return callback err if err
        callback err, {resp, body}
    async.retry 3, fn, (err, x) ->
      return cb err if err
      cb err, x.resp, x.body

module.exports = utils
