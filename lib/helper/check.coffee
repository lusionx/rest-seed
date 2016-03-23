_               = require 'lodash'
tv4             = require 'tv4'


module.exports =
  params: (schema, path='params') ->
    (req, res, next) ->
      return next() if not schema
      v = _.get req, path
      result = tv4.validateMultiple v, schema
      return next() if result.valid
      ls = _.map result.errors, (e) -> _.pick e, ['message', 'params', 'dataPath']
      res.json 409, {code: 'tv4params', results: ls}
      next no
