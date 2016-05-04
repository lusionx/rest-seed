_         = require 'lodash'
async     = require 'async'

utils     = require '../lib/utils'
config    = require '../configs'
helper    = require './helper'


tv4 =[
  helper.check.params
    type: 'object'
    properties:
      access_token:
        type: 'string'
    required: ['access_token']
  (req, res, next) ->
    res.json req.params
    next()
]

module.exports = {tv4}
