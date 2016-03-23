moment  = require 'moment'
_       = require 'lodash'
async   = require 'async'

utils   = require '../../lib/utils'


module.exports = (midw, _hook, life=60, getK) ->
  (req, res, next) ->
    k = getK? req
    return midw req, res, next if not _.isString k
    return midw req, res, next if not k
    utils.getCache k, (err, v) ->
      if v
        req.hooks[_hook] = v
        return next()
      midw req, res, (err) ->
        return next err if err
        v = req.hooks[_hook]
        return next err if not v
        utils.setCache k, v, life, next
