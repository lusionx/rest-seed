rest = require "./lib/initialize"

rest.Router     = require "./lib/router"
rest.helper     = require "./lib/helper"
rest.utils      = require "./lib/utils"
rest.restify    = require "restify"

# 异常处理，尽量保证服务不要宕掉
process.on 'uncaughtException', (error) ->
  console.error new Date
  console.error error
  console.error error.stack

module.exports = rest
