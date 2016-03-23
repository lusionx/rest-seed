_       = require 'lodash'
should  = require 'should'

root    = require '../root'

logger  = root.logger

describe '/test', () ->
  it 'tv4 409', (done) ->
    par =
      uri: '/test'
    root.request par, (err, resp, body) ->
      logger.debug body
      resp.statusCode.should.be.eql 409
      done()
  it 'tv4 ok', (done) ->
    par =
      uri: '/test'
      qs:
        access_token: 'asdsadsa'
    root.request par, (err, resp, body) ->
      logger.debug body
      resp.statusCode.should.be.eql 200
      done()
