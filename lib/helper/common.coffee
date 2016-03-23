utils = require '../../lib/utils'
_     = require 'lodash'


common =
  jsonp: (_hooks, origin) -> # 使用jsonp 的方式返回数据
    (req, res, next) ->
      obj = req.hooks[_hooks]
      return next() if not obj
      if method = (req.params.callback or req.params.jsonp)
        res.contentType = 'application/javascript'
        res.end method + '(' + JSON.stringify(obj) + ')'
      else
        res.header 'Access-Control-Allow-Origin', '*' if origin
        res.json obj
      next()

  redirect: (_hooks='redirect') -> # 跳转地址
    (req, res, next) ->
      if uri = req.hooks[_hooks]
        res.header 'Location', uri
        res.send 302, null
      next()

  # 包装中间件, 以当时的req, res 控制是否运行
  # params fns: function, [function] | (req, res, next) -> 典型中间件
  # params cond: (req, res) -> | 返回bool 确定中间件是否运行
  wrapIf: (fns, cond) ->
    fns = [fns]
    fns = _.flatten fns, yes
    _.map fns, (e) ->
      (req, res, next) ->
        foo = cond req, res
        if foo
          e req, res, next
        else
          next()

module.exports = common
