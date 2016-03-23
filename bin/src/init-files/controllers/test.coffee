_         = require 'lodash'
async     = require 'async'

utils     = require '../lib/utils'
config    = require '../configs'
helper    = require './helper'


tv4 =[
  helper.check.params
    type: 'object'
    properties:
      data:
        type: 'access_token'
    required: ['access_token']
  (req, res, next) ->
    res.json req.params
    next()
]

module.exports = {tv4}
