fs           = require 'fs'
path         = require 'path'
HOMEDIR      = path.join(__dirname,'..')
LIB_COV      = path.join(HOMEDIR,'lib-cov')
LIB_DIR      = if fs.existsSync(LIB_COV) then LIB_COV else path.join(HOMEDIR,'lib')
Intellinote  = require(path.join(LIB_DIR, 'intellinote')).Intellinote
assert       = require('assert')
ACCESS_TOKEN = process.env.ACCESS_TOKEN
BASE_URL     = process.env.INTELLINOTE_HOST

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
  console.error "          https://app.us.team-one.com/rest/account/api-tokens"
  console.error "\x1b[1;31m"
  console.error "Aborting test execution due to missing ACCESS_TOKEN."
  console.error "\x1b[0m"
  process.exit(1)
else

  describe 'Intellinote Client',->

    it 'exists', (done)->
      assert Intellinote?
      done()

    # # We've disabled this test since it is hard-coded to a specific
    # # org/ws and creates real files. Re-enable it for one-off testing
    # # as needed
    # it 'can post files', (done)->
    #   @timeout 10000
    #   client = new Intellinote(access_token:ACCESS_TOKEN)
    #   input = fs.createReadStream(path.join(HOMEDIR,'README.md'))
    #   client.post_file 23343, 139114, input, (err, json, response, body)=>
    #    console.log err, json, response?.statusCode, body
    #    done()

    it 'can fetch my user profile', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
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

    it 'can pass extra query-string parameters', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
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
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.getEcho (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.method is 'GET'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit POST requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.postEcho {foo:"bar"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo is 'bar'
        assert resp.method is 'POST'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit PUT requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.putEcho {foo2:"bar2"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo2 is 'bar2'
        assert resp.method is 'PUT'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit PATCH requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.patchEcho {foo3:"bar3"}, (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.body.foo3 is 'bar3'
        assert resp.method is 'PATCH'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit DELETE requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.deleteEcho (err, resp)->
        assert not err?
        assert typeof resp is 'object'
        assert resp.method is 'DELETE'
        assert resp.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can submit custom GET requests', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
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
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.post "/echo", {foo:"bar"}, null, {"x-custom-header":"found"}, (err, json, response, body)->
        assert not err?
        assert typeof json is 'object'
        assert json.body.foo is 'bar'
        assert json.method is 'POST'
        assert json.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        assert json.headers["x-custom-header"] is "found"
        done()

    it 'can submit custom PUT requests, with query string', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.put "/echo", {foo:"bar"}, {x:"y"}, (err, json, response, body)->
        assert not err?
        assert json?
        assert typeof json is 'object'
        assert json.body.foo is 'bar'
        assert json.query.x is 'y'
        assert json.method is 'PUT'
        assert json.headers.authorization is "Bearer #{ACCESS_TOKEN}"
        done()

    it 'can handle error responses - bad token case', (done)->
      client = new Intellinote(access_token:"not a real token", base_url:BASE_URL)
      client.get "/user/-", (err, ignored, response, body)->
        assert err?, body
        assert /Active authorization bearer token required/.test err.message
        done()

    it 'can handle error responses - bad URL case', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.get "/this/path/does/not/exist/user/-", (err, ignored, response, body)->
        assert err?
        assert /Expected 2xx status code, found 404/.test err.message
        done()

    it 'can fetch and set my presence status', (done)->
      client = new Intellinote(access_token:ACCESS_TOKEN, base_url:BASE_URL)
      client.getUserPresenceStatus "-", (err, response)->
        assert not err?, err
        assert.equal response.ok, true
        assert response.user_id?
        assert response.presence_code?
        original_presence_code = response.presence_code
        client.putUserPresenceStatus "-", {presence_code:"busy-meeting-mobile"}, (err, response)->
          assert not err?, err
          assert.equal response.ok, true
          client.getUserPresenceStatus "-", (err, response)->
            assert not err?, err
            assert.equal response.ok, true
            assert response.user_id?
            assert.equal response.presence_code, "5d"
            client.putUserPresenceStatus "-", {presence_code:original_presence_code}, (err, response)->
              assert not err?, err
              assert.equal response.ok, true
              client.getUserPresenceStatus "-", (err, response)->
                assert not err?, err
                assert.equal response.ok, true
                assert response.user_id?
                assert.equal response.presence_code, original_presence_code
                done()
