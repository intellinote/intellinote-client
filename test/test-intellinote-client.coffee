fs           = require 'fs'
path         = require 'path'
HOMEDIR      = path.join(__dirname,'..')
LIB_COV      = path.join(HOMEDIR,'lib-cov')
LIB_DIR      = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Intellinote  = require(path.join(LIB_DIR, 'intellinote')).Intellinote
assert       = require('assert')
ACCESS_TOKEN = process.env.ACCESS_TOKEN

unless ACCESS_TOKEN?
  console.error "\x1b[0;31m"
  console.error "ERROR: In order to run the unit test suite you must set the"
  console.error "       environment variable named 'ACCESS_TOKEN'."
  console.error "\x1b[0;31m"
  console.error "       For example:"
  console.error "\x1b[0;32m"
  console.error "          ACCESS_TOKEN=my-token make test"
  console.error "\x1b[0;31m"
  console.error "       If you have an Intellinote account, you may obtain a token at:"
  console.error "\x1b[1;34m"
  console.error "          https://app.intellinote.net/rest/account/api-tokens"
  console.error "\x1b[1;31m"
  console.error "Aborting test execution due to missing ACCESS_TOKEN."
  console.error "\x1b[0m"
  process.exit(1)
else

  describe 'Intellinote Client',->

    it 'exists', (done)->
      assert Intellinote?
      done()

    it 'can fetch my user profile', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.getUser "-", (err, user)->
        assert user?
        assert user.user_id?
        assert user.given_name?
        assert user.family_name?
        assert user.email?
        assert user.avatar?
        assert /^https?:\/\//.test(user.avatar)
        assert user.orgs?
        assert user.orgs.length > 0
        done()

    it 'can pass extra query-string parameters (abd accepts access token as string)', (done)->
      client = new Intellinote(ACCESS_TOKEN)
      client.getUser "-", {inline_avatars:true}, (err, user)->
        assert user?
        assert user.user_id?
        assert user.given_name?
        assert user.family_name?
        assert user.email?
        assert user.avatar?
        assert /^data:image\/((png)|(jpe?g));base64,[A-Za-z0-9+=\/]+$/.test(user.avatar)
        assert user.orgs?
        assert user.orgs.length > 0
        done()

    it 'can submit GET requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.getEcho (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.method is 'GET'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit POST requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.postEcho {foo:"bar"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo is 'bar'
        assert resp.method is 'POST'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit PUT requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.putEcho {foo2:"bar2"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo2 is 'bar2'
        assert resp.method is 'PUT'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit PATCH requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.patchEcho {foo3:"bar3"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo3 is 'bar3'
        assert resp.method is 'PATCH'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit DELETE requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.deleteEcho (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.method is 'DELETE'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit custom GET requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.get "/user/-", (err, ignored, response, body)->
        assert not err?
        assert body?
        assert typeof body is 'string'
        json = JSON.parse(body)
        assert json.user_id?
        assert json.given_name?
        assert json.family_name?
        assert json.email?
        assert json.avatar?
        assert /^https?:\/\//.test(json.avatar)
        assert json.orgs?
        assert json.orgs.length > 0
        done()

    it 'can submit custom POST requests, with custom headers', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.post "/echo", null, {foo:"bar"}, {"x-custom-header":"found"}, (err, json, response, body)->
        assert not err?
        assert typeof json is 'object'
        assert json.body.foo is 'bar'
        assert json.method is 'POST'
        assert json.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        assert json.headers["x-custom-header"] is "found"
        done()

    it 'can submit custom PUT requests, with query string', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN)
      client.put "/echo", {x:"y"}, {foo:"bar"}, (err, json, response, body)->
        assert not err?
        assert json?
        assert typeof json is 'object'
        assert json.body.foo is 'bar'
        assert json.query.x is 'y'
        assert json.method is 'PUT'
        assert json.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()
