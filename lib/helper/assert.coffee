_       = require 'lodash'

# assert 所有的方法都可能随时会调用next error
# assert 的思路就是判断，如果发现不一致的数据，就返回异常

module.exports =
  # 检测某字段是否与指定的值是否相同，如果不同则报错
  equal: (field, value, _obj, msg, code=400) ->
    (req, res, next) ->
      excepted = (_obj and req.hooks[_obj] or req.params)[field]
      unless excepted is value
        res.json code, {message: msg}
        return next no
      next()

  # 检测某字段是否与指定的值是否不相同，如果相同则报错
  notEqual: (field, value, _obj, msg, code=400) ->
    (req, res, next) ->
      excepted = (_obj and req.hooks[_obj] or req.params)[field]
      if excepted is value
        res.json code, {message: msg}
        return next no
      next()

  # 检测某个字段是否在某个数组里包含
  inArray: (key1, obj1, key2, obj2, msg, code=400) ->
    (req, res, next) ->
      value1 = req.hooks[obj1][key1]
      value2 = req.hooks[obj2][key2]
      value2 = value2.split(',') if _.isString value2
      value2 = _.map(value2, (x) -> +x) if _.isNumber value1
      unless value1 in value2
        res.json code, {message: msg}
        return next no
      next()

  # 检测是否存在
  exists: (hook, msg = '', code=404) ->
    (req, res, next) ->
      model = req.hooks[hook]
      if not model
        res.json code, {message: msg}
        return next no
      next()

