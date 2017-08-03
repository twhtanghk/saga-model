_ = require 'lodash'
{ put, take, select } = require 'redux-saga/effects'
rest = require 'redux-saga-rest'
stampit = require 'stampit'

# return parsed json body or throw error
json = (req, next) ->
  res = yield next req
  try
    res.data = yield res.json()
  catch error
    throw new Error res.statusText
  if res.ok
    return res
  else
    throw new Error(res.data.message || res.statusText)

###
loop for
  acquire oauth2 token
  send req
  if unauthorized
    login till resolved or rejected
  else
    return res
###
auth = (orgReq, next) ->
  while true
    req = orgReq.clone()
    token = yield select (state) ->
      state.auth.token
    headers = req.headers || new Headers()
    headers.set 'Authorization', "Bearer #{token}"
    res = yield next new Request req, { headers }
    if res.status == 401
      yield put type: 'login'
      yield take [
        'loginResolve'
        'loginReject'
      ]
      error = yield select (state) ->
        state.auth.error
      if error?
        throw new Error error
    else
      return res

module.exports = (baseUrl) ->
  stamp = stampit()
    .init (props) ->
      _.extend @, @parse(props)
    .methods
      getStamp: ->
        stamp
      isNew: ->
        not @[@getStamp().idAttribute]?
      parse: (data = {}) ->
        data
      fetch: ->
        stamp.api.get stamp.url(@[@getStamp().idAttribute])
      save: (values = {}) ->
        _.extend @, values
        if @isNew()
          stamp.api.post stamp.url(), @
        else
          stamp.api.put stamp.url(@[@getStamp().idAttribute]), @
      destroy: ->
        stamp.api.del stamp.url(@[@getStamp().idAttribute])
  .statics
    idAttribute: 'id'
    api: (new rest.API baseUrl)
      .use auth
      .use json
    baseUrl: baseUrl
    url: (id = '.') ->
      url = require 'url'
      path = require 'path'
      ret = url.parse @baseUrl
      ret.pathname = path.join ret.pathname, id
      url.format ret
    fetchOne: (id) ->
      props = {}
      props[@idAttribute] = id
      @(props).fetch()
    fetchAll: (data = null) ->
      if data?
        headers = new Headers
          'Content-Type': 'application/json'
          'x-http-method-override': 'get'
        @api.post stamp.url(), data, { headers }
      else
        @api.get stamp.url()
