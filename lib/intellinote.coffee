request          = require 'request'
FormData         = require 'form-data'
url              = require 'url'
DEBUG            = /(^|,)(intell)?inote(-?api)?(-?client)?(,|$)/i.test process.env.NODE_DEBUG
DEFAULT_BASE_URL = "https://api.intellinote.net/rest/v2"

###############################################################################
#### API METHOD DEFINITION
###############################################################################

# Data used to generate specific API-invoking methods based on a template.
# See `_make_api_method`.
#
# format:
#  keys - "<METHOD> <PATH>" where path may contain `{0}`, `{1}` etc. as
#         positional parameters
#  values - [ <NUM_PATH_PARAMS>, [ <METHOD_NAMES> ]]
API_METHODS = {
  # GET
  "GET /echo"                                : [ 0, [ "get_echo"                 , "getEcho"              ] ]
  "GET /note/{0}"                            : [ 1, [ "get_note"                 , "getNote"              ] ]
  "GET /notes"                               : [ 0, [ "get_notes"                , "getNotes"             ] ]
  "GET /org/{0}"                             : [ 1, [ "get_org"                  , "getOrg"               ] ]
  "GET /org/{0}/members"                     : [ 1, [ "get_org_members"          , "getOrgMembers"        ] ]
  "GET /org/{0}/workspace/{1}"               : [ 2, [ "get_workspace"            , "getWorkspace"         ] ]
  "GET /org/{0}/workspace/{1}/members"       : [ 2, [ "get_workspace_members"    , "getWorkspaceMembers"  ] ]
  "GET /org/{0}/workspaces"                  : [ 1, [ "get_workspaces_in_org"    , "getWorkspacesInOrg"   ] ]
  "GET /orgs"                                : [ 0, [ "get_orgs"                 , "getOrgs"              ] ]
  "GET /ping"                                : [ 0, [ "get_ping"                 , "getPing"              ] ]
  "GET /user/{0}"                            : [ 1, [ "get_user"                 , "getUser"              ] ]
  "GET /user/{0}/presence"                   : [ 1, [ "get_user_presence"        , "getUserPresence"      ] ]
  "GET /users"                               : [ 0, [ "get_users"                , "getUsers"             ] ]
  "GET /users/dt"                            : [ 0, [ "get_users_dt"             , "getUsersDT"           ] ]
  "GET /workspaces"                          : [ 0, [ "get_workspaces"           , "getWorkspaces"        ] ]
  # POST
  "POST /echo"                               : [ 0, [ "post_echo"                , "postEcho"             ] ]
  "POST /org"                                : [ 0, [ "post_org"                 , "postOrg"              ] ]
  "POST /org/{0}/member/{1}"                 : [ 2, [ "post_org_member"          , "postOrgMember"        ] ]
  "POST /org/{0}/user/{1}/message"           : [ 2, [ "postMessageToUser", "post_direct_message", "postDirectMessage", "post_dm", "postDM", "post_user_message", "postUserMessage" ] ]
  "POST /org/{0}/workspace"                  : [ 1, [ "post_workspace"           , "postWorkspace"        ] ]
  "POST /org/{0}/workspace/{1}/member/{2}"   : [ 3, [ "post_workspace_member"    , "postWorkspaceMember"  ] ]
  "POST /org/{0}/workspace/{1}/message"      : [ 2, [ "postMessageToWorkspace", "post_chat_message", "postChatMessage", "post_message", "postMessage", "post_workspace_message", "postWorkspaceMessage" ] ]
  "POST /org/{0}/workspace/{1}/note"         : [ 2, [ "post_note"                , "postNote"             ] ]
  "POST /user"                               : [ 0, [ "post_user"                , "postUser"             ] ]
  # PATCH
  "PATCH /echo"                              : [ 0, [ "patch_echo"               , "patchEcho"            ] ]
  # PUT
  "PUT /echo"                                : [ 0, [ "put_echo"                , "putEcho"               ] ]
  "PUT /org/{0}"                             : [ 1, [ "put_org"                 , "putOrg"                ] ]
  "PUT /org/{0}/member/{1}"                  : [ 2, [ "put_org_member"          , "putOrgMember"          ] ]
  "PUT /org/{0}/workspace/{1}"               : [ 2, [ "put_workspace"           , "putWorkspace"          ] ]
  "PUT /org/{0}/workspace/{1}/member/{2}"    : [ 3, [ "put_workspace_member"    , "putWorkspaceMember"    ] ]
  "PUT /org/{0}/workspace/{1}/note/{2}"      : [ 3, [ "put_note"                , "putNote"               ] ]
  "PUT /user/-/presence"                     : [ 0, [ "put_user_presence"       , "putUserPresence"       ] ]
  "PUT /user/{0}"                            : [ 1, [ "put_user"                , "putUser"               ] ]
  # DELETE
  "DELETE /echo"                             : [ 0, [ "delete_echo"             , "deleteEcho"            ] ]
  "DELETE /org/{0}"                          : [ 1, [ "delete_org"              , "deleteOrg"             ] ]
  "DELETE /org/{0}/member/{1}"               : [ 2, [ "delete_org_member"       , "deleteOrgMember"       ] ]
  "DELETE /org/{0}/workspace/{1}"            : [ 2, [ "delete_workspace"        , "deleteWorkspace"       ] ]
  "DELETE /org/{0}/workspace/{1}/member/{2}" : [ 3, [ "delete_workspace_member" , "deleteWorkspaceMember" ] ]
  "DELETE /org/{0}/workspace/{1}/note/{2}"   : [ 3, [ "delete_note"             , "deleteNote"            ] ]
  "DELETE /user/{0}"                         : [ 1, [ "delete_user"             , "deleteUser"            ] ]
}

class Intellinote

  # Configuration options:
  #  `access_token` - oauth access token (required)
  #  `base_url` - base URL for REST methods (defaults to `https://api.intellinote.net/rest/v2`)
  #  `debug` - when true, extra debugging output is written to stdout
  constructor:(config)->
    config ?= {}
    if typeof config is 'string'
      config = {access_token:config}
    @access_token = config.access_token ? config.accessToken ? config.accesstoken
    @base_url = config.base_url ? DEFAULT_BASE_URL
    parsed_url = url.parse(@base_url)
    @base_url_protcol = parsed_url.protocol
    @base_url_host = parsed_url.host
    if parsed_url.port?
      @base_url_port = parsed_url.port
    @base_url_path = parsed_url.path
    @debug = config.debug ? DEBUG
    @_generate_api_methods()

  ##############################################################################
  #### SPECIAL CASE METHODS
  ##############################################################################

  postFile:(org_id, ws_id, read_stream, qs, headers, callback)=>
    @post_file(org_id, ws_id, read_stream, qs, headers, callback)

  post_file:(org_id, ws_id, read_stream, qs, headers, callback)=>
    [qs, headers, callback] = @_resolve_qs_headers_callback(qs, headers, callback)
    req_path = "/org/#{org_id}/workspace/#{ws_id}/file"
    params = @_to_params req_path, qs, null, headers
    params.formData = {file:read_stream}
    @_execute_api_request "post", params, callback

  ##############################################################################
  #### API METHOD CREATION
  ##############################################################################

  # Walks thru the `API_METHODS` list, generating member functions.
  _generate_api_methods :()=>
    for n, v of API_METHODS
      [req_method, req_path] = n.split(/\s+/,2)
      num_args = v[0]
      method_names = v[1]
      for name in method_names
        @[name] = @_make_api_method req_method.toLowerCase(), num_args, req_path

  # Makes a single member function to execute the specified REST endpoint
  # `req_method`  - `get`, `put`, `post` or `delete`
  # `num_args`    - number of method arguments (excluding `options` and `callback`)
  #                 which corresponds to the number of path-parameters.
  # `req_path`    - the endpoint's path, relative to `base_url`.
  _make_api_method:(req_method,num_args,req_path)=>
    return (args...)=>
      values = args[0...num_args]
      tail = args[num_args...]
      if req_method in ['put','post','patch']
        body = tail.shift()
      [qs, headers, callback] = @_resolve_qs_headers_callback tail...
      fpath = @_sprintf req_path, values...
      unless @_access_token_missing callback
        params = @_to_params fpath, qs, body, headers
        @_execute_api_request req_method, params, callback


  ##############################################################################
  #### "GENERIC" REQUEST METHODS
  ##############################################################################
  # these allow arbitrary requests as an "escape route" should clients need
  # anything not explicity covered

  # Arbitrary `GET` request.
  # callback:(err, json, response, body)
  get:(path, qs, headers, callback)=>
    @_execute_arbitrary_request "get", path, qs, null, headers, callback

  # Arbitrary `DELETE` request.
  # callback:(err, json, response, body)
  del:(path, qs, headers, callback)=>
    @_execute_arbitrary_request "delete", path, qs, null, headers, callback

  delete:(path, qs, headers, callback)=>
    @del(path, qs, headers, callback)

  # Arbitrary `POST` request.
  # callback:(err, json, response, body)
  post:(path, body, qs, headers, callback)=>
    @_execute_arbitrary_request "post", path, qs, body, headers, callback

  # Arbitrary `PUT` request.
  # callback:(err, json, response, body)
  put:(path, body, qs, headers, callback)=>
    @_execute_arbitrary_request "put", path, qs, body, headers, callback

  # Arbitrary `PATCH` request.
  # callback:(err, json, response, body)
  patch:(path, body, qs, headers, callback)=>
    @_execute_arbitrary_request "patch", path, qs, body, headers, callback

  ##############################################################################
  #### API METHOD EXECUTION
  ##############################################################################

  # generate a request "params" map for the given path,
  # (optional) query string and (optional) request body.
  # An `Authorization` header is automatically added.
  _to_params:(req_path, qs, body, headers)=>
    params = {}
    params.url = @_append_qs "#{@base_url}#{req_path}", qs
    if body?
      if typeof body is 'object'
        params.json = body
        params.headers ?= {}
        params.headers["Content-Type"] ?= "application/json"
      else
        params.form = body
    if @access_token?
      params.headers ?= {}
      params.headers = { Authorization: "Bearer #{@access_token}" }
    if headers?
      params.headers ?= {}
      for n, v of headers
        params.headers[n] = v
    return params

  # Converts a map of name-value pairs to a query string.
  #
  # Keys that map to null become `<name>` in the query string.
  # Keys that map to a blank string become `<name>=` in the query string.
  # Keys that map to non-blank strings become `<name>=<value>` in the query string.
  # Keys that map to arrays are repeated--once for each element of the array.
  # Both names and values are URI-encoded automatically.
  _map_to_qs:(map)=>
    unless map?
      return null
    else
      parts = []
      for n,v of map
        unless v?
          parts.push encodeURIComponent(n)
        else if Array.isArray(v)
          for elt in v
            parts.push "#{encodeURIComponent(n)}=#{encodeURIComponent(elt)}"
        else
          parts.push "#{encodeURIComponent(n)}=#{encodeURIComponent(v)}"
      if parts.length is 0
        return null
      else
        return parts.join("&")

  # Convert the given map into a query string,
  # then append it to the given URL/path, respecting
  # whether or not `?` already exists in the given URL.
  _append_qs:(req_path,map)=>
    qs = @_map_to_qs(map)
    if qs?
      req_path ?= ""
      if /\?/.test req_path
        return "#{req_path}&#{qs}"
      else
        return "#{req_path}?#{qs}"
    else
      return req_path

  # If `@access_token` is not set, calls back with an error and returns `true`
  _access_token_missing:(callback)=>
    if @access_token?
      return false
    else
      callback(new Error("Missing auth token."))
      return true

  _execute_arbitrary_request:(method, req_path, qs, body, headers, callback)=>
    if typeof qs is 'function' and not body? and not headers? and not callback?
      callback = qs
      qs = null
    else if typeof body is 'function' and not headers? and not callback?
      callback = body
      body = null
    else if typeof headers is 'function' and not callback?
      callback = headers
      headers = null
    params = @_to_params(req_path, qs, body, headers)
    @_execute_api_request(method, params, callback)

  __body_to_err_string:(body)=>
    unless body?
      return "(null)"
    else if typeof body in ['string','number','boolean']
      return "#{body}"
    else
      try
        return JSON.stringify(body)
      catch err
        return "#{body}"

  _execute_api_request:(method, params, callback)=>
    @_log_request method, params
    start_time = process.hrtime()
    if method is 'delete'
      method = 'del'
    request[method] params, (err, response, body)=>
      delta = process.hrtime(start_time)
      @_log_request_duration delta
      @_read_json_response err, response, body, callback

  _read_response:(err, response, body, callback)=>
    if err?
      callback err, null, response, body
    else unless response?
      callback new Error "Expected non-null response object.", null, response, body
    else unless response.statusCode >= 200 and response.statusCode <= 299
      callback new Error "Expected 2xx status code, found #{response.statusCode}. Response body: #{@__body_to_err_string(body)}", null, response, body
    else
      callback null, null, response, body

  # Convert the given HTTP response to a JSON document (if possible).
  # Reports an error if:
  #  - there is no response, status code or body
  #  - the status code is not in the 2xx series.
  # If the body cannot be converted to JSON, `null` is returned
  # for the JSON parameter.
  #
  # callback signature: (err, json, response, body)
  _read_json_response:(err, response, body, callback)=>
    @_read_response err, response, body, (err, ignored, response, body)=>
      if err?
        callback(err)
      else unless body?
        if response.statusCode is 204
          callback null, null, response, body
        else
          callback new Error "Expected a non-null response body.", null, response, body
      else
        json = body
        if typeof json is 'string'
          try
            json = JSON.parse(json)
          catch e
            json = null
        callback null, json, response, body

  # returns [options, callback] after accounting for the optional `options` parameter.
  _resolve_qs_headers_callback:(qs,headers,callback)=>
    if typeof qs is 'function' and not headers? and not callback?
      callback = qs
      qs = null
    else if typeof headers is 'function' and not callback?
      callback = headers
      headers = null
    qs ?= {}
    headers ?= {}
    callback ?= (()->undefined)
    return [qs, headers, callback]

  # Resolve positional parameters of the form `{i}` by replacing them with the
  # ith value in `values`.
  _sprintf:(str, values...)=>
    if str?
      unless typeof str is 'string'
        str = "#{str}"
      str = str.replace /{(\d+)}/g, (match, index)->
        if typeof values[index] is "undefined"
          return match
        else
          return values[index]
    return str

  ##############################################################################
  #### DEBUG AND ERROR REPORTING
  ##############################################################################

  # Write `message` to stdout if `@debug` is true.
  _debug_message:(message...)=>
    if @debug
      console.log "#{(new Date()).toISOString()} [DEBUG] intellinote>", message...

  # Write `message` to stderr.
  _error_message:(message...)=>
    console.error "#{(new Date()).toISOString()} [ERROR] intellinote>", message...

  # Generate a debugging message for the given request.
  _log_request:(method,params)=>
    @_debug_message "#{method.toUpperCase()} #{params?.uri ? params.url ? params.pathname ? params.path}","#{JSON.stringify(params)}"

  # Generate a debugging message for the given request duration.
  _log_request_duration:(duration)=>
    @_debug_message "elapsed time: #{duration[0]}.#{duration[1]} seconds."

exports.Intellinote = exports.IntellinoteClient = Intellinote
