_         = require 'lodash'
async     = require 'async'
rest      = require 'rest-seed'
conf      = require '../configs'

modelNames = null

utils =
  method: ->

module.exports = _.extend utils, rest.utils
