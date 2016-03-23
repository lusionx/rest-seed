_     = require 'lodash'

conf = require "./config.#{process.env.webmode or 'development'}"

ext =
  privateIps: [
  ]
  privateEmails: [
  ]

module.exports = _.extend {}, ext, conf
