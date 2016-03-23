requestOri  = require 'request'
log4js      = require 'log4js'
_           = require 'lodash'



api = (p) ->
  'http://127.0.0.1:8100' + p

request = (par, callback) ->
  par.uri = api par.uri if par.uri
  par.url = api par.url if par.url
  requestOri par, (err, resp, body) ->
    try o = JSON.parse body if _.isString body
    callback err, resp, o or body




module.exports = {api, request, logger: log4js.getLogger()}
