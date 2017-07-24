# saga-model

[ActiveRecord](https://bfanger.nl/angular-activerecord/api/#!/api/ActiveRecord) like [stamp](https://github.com/stampit-org/stampit) via [Redux Saga Rest](https://github.com/zach-waggoner/redux-saga-rest)

## Configuration
```
npm install saga-model
```

## API
1. Model(baseUrl): create stamp with input baseUrl
2. static:
  - idAttribute: 'id' (default)
  - baseUrl: specified baseUrl for restful api
  - api: saga rest api with pre-defined middleware auth and json
  - url(path = '.'): function to return url for specified relative path
  - fetchOne(id): restful get instance with specified id
  - fetchAll(data = null): restful get list of instance with specified data
3. method:
  - getStamp(): return stamp of this object
  - isNew(): return if object a new object without id
  - parse(data = {}): return post prcoessed data of http response data
  - fetch(): load single record from rest server
  - save(values = {}): save records combined with input values into rest server
  - destroy(): destroy this instance on the rest server
4. middleware:
  - json: parse response body stream and save result into res.data, also throw error if not res.ok
  - auth: acquire oauth2 token till login resolved or rejected

## Create customized stamp on top of ActiveRecord like Steamp
1. stampCreator = require 'saga-model' 
2. create default stamp with specified url (e.g. #{location.href}/api/user)
3. compose stamp with extended staic or instance methods
