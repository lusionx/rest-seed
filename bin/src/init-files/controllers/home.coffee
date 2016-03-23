_         = require 'lodash'
async     = require 'async'

utils     = require '../lib/utils'
config    = require '../configs'
helper    = require './helper'


module.exports =
  index: (req, res, next) ->
    res.end "Hello world, now is: #{new Date}"
    next()

  session: [
    (req, res, next) ->
      d =
        user: req.user
      res.json d
      next()
  ]
