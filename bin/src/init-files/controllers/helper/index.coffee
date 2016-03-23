_     = require 'lodash'
utils = require '../../lib/utils'
rest  = require 'rest-seed'

modules = {}
for file in utils.readdir(__dirname, ['coffee', 'js'], ['index', 'defaults'])
  moduleName = utils.file2Module file
  modules[moduleName] = require "./#{file}"

modules = _.extend modules, rest.helper

module.exports = modules
