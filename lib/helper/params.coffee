_         = require 'lodash'

params =

  # 忽略掉指定属性
  omit: (omitValues...) ->
    (req, res, next) ->
      return next() unless req.params?
      req.params = _.omit(req.params, omitValues)
      next()

  # 将 parmas 的可以做一个简单的映射
  map: (dict) ->
    (req, res, next) ->
      for k, v of dict
        req.params[v] = req.params[k]
      next()

module.exports = params

