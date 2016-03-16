_         = require 'lodash'
utils     = require './utils'

# 路由器初始化
# params
#   server object restify.createServer()
#   controller ./controller
module.exports = (server, ctls, opts = {}) ->

  apis = []

  # 判断是否需要提供apis的查询接口
  if opts.apis
    server.get opts.apis, (req, res, next) ->
      res.send apis
      next()

  register = (verb, routePath, ctlAct) ->

    # 暂存起来，提供给apis接口来用
    # apis接口用来返回当前 services 提供的可用的 api
    apis.push "[#{verb.toUpperCase()}] #{routePath}"

    [ctl, action] = ctlAct.split('#')

    # 如果定义的对应的控制器，也有对应的方法则使用该方法
    actions = ctls[ctl][action] if ctls[ctl] and ctls[ctl][action]

    # 如果都没有则抛出异常
    throw Error "控制器缺少route指定的方法" unless actions

    # 如果actions是数组，则把数组弄成一维的
    actions = _.flatten actions if _.isArray actions

    # 强制把actions处理成一个数组
    actions = [actions] unless _.isArray actions

    # 过滤掉空
    actions = _.filter(actions, (x) -> x)

    # 将每一个action都用try catch处理
    actions = _.map(actions, (action) ->
      (req, res, next) ->
        try
          action(req, res, next)
        catch e
          console.error e
          console.error e.stack
          next(e)
    )
    server[verb].apply server, [routePath].concat actions

  router = {}
  _.each(['get', 'post', 'put', 'patch', 'del'], (verb) ->
    router[verb] = (routePath, ctlAct) ->
      register verb, routePath, ctlAct
  )
  router
