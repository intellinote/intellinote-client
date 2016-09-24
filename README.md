# Intellinote REST Client for JavaScript / Node.js

This module contains a Node.js class that wraps the [Intellinote REST API (v2)](https://api.intellinote.net/rest/api/v2/) in a simple interface.

## Obtaining

### Via npm

A pre-"compiled" version of this module is published on [npm](https://www.npmjs.com/package/intellinote-cli) as [`intellinote-client`](https://www.npmjs.com/package/intellinote-cli).  

Run `npm install --save intellinote-client` to add it as a dependency in your `package.json`.

### Via Git

The source code for this module is published on [GitHub](https://github.com/) as [`intellinote/intellinote-client`](https://github.com/intellinote/inote-util).  

Clone the repository with `git clone git@github.com:intellinote/inote-util.git` and then run `make install` (or `npm install`) to install the external libraries that are needed.

## Using

To use the library you'll need an OAuth2 "access-token" value, which you can obtain via the OAuth2 process or generate at <https://api.intellinote.net/rest/account/api-tokens>.

Once installed, the usage is straightforward:

```js
var MY_ACCESS_TOKEN = "replace with your access token";
var IntellinoteClient = require("intellinote-client").IntellinoteClient;

var client = new IntellinoteClient(MY_ACCESS_TOKEN);

client.getNotes({note_type:"CHAT"},function (err, notes) {
  if(err) {
    console.error("An error occurred:",err);
  } else {
    console.log("Here are your most recent chat messages:");
    console.log(JSON.stringify(notes,null,2));
  }
})
```

Each API method directly corresponds with a REST endpoint (as described [here](https://api.intellinote.net/rest/api/v2/)). In the example above, the `client.getNotes` call corresponds to [`GET /notes`](https://api.intellinote.net/rest/api/v2/#!/notes/get_notes).

Each API method accepts a set of parameters which depend upon the specific method to be invoked.  In the most general form, each API method has the following signature:

```js
function apiMethod( [PATH_PARAMETERS...,] [BODY,] [QS, [HEADERS,]] CALLBACK)
```

Where:

 * `PATH_PARAMETERS` is zero or more values that would normally appear in the path part of the REST method's URL.  For example, the method:

   ```
   GET /org/{ORG_ID}/workspace/{WORKSPACE_ID}/members
   ```

   has two "path parameters"&mdash;`ORG_ID` and `WORKSPACE_ID`.  Hence the signature for this method in `IntellinoteClient` is

   ```js
   function getWorkspaceMembers(orgId, workspaceId, qs, headers, callback)
   ```

   when a method accepts no "path parameters" this argument is simply omitted.


  * The `BODY` parameter is only used for `POST`, `PUT` and `PATCH` methods. It should contain a JSON object that will be submitted as the body of the HTTP request.


  * The `QS` parameter is optional and may contain a map of name/value pairs that will be added to the request as query-string parameters.


  * The `HEADERS` parameter is also optional and may contain a map of name/value pairs that will be added as request headers.  Note that if `HEADERS` is used, there must be _some_ value passed for `QS`, potentially `null`.  That is the map in `someGetMethod({foo:"bar"},callback)` will be interpreted as a collection of query-string parameters. To convice the client to interpret these values as headers, you may use `someGetMethod(null,{foo:"bar"},callback)` or `someGetMethod({},{foo:"bar"},callback)`.


  * Finally a callback method is passed.  That method is expected to have the signature `err, json, response, body`, where

    - `err` is an `Error` object, if an error occurred.
    - `json` is an object generated by parsing the response body as JSON. If the body is missing or cannot be parsed as JSON, this parameter will be `null`.
    - `response` is the response object as returned by the underlying [request](https://github.com/request/request) API.
    - `body` is the HTTP response body (if any).  This is especially useful when the body is a non-JSON response.

## The API Methods

See [the Intellinote REST API documentation](https://app.intellinote.net/rest/api/v2/) for more information about these methods.

### Fetching
  * `getNote( noteID_or_noteUUID, [qs, [headers,]] callback )`
  * `getNotes( [qs, [headers,]] callback )`
  * `getOrg ( orgID, [qs, [headers,]] callback )`
  * `getOrgMembers( orgID, [qs, [headers,]] callback )`
  * `getOrgs( [qs, [headers,]] callback )`
  * `getUser( userID_or_emailAddr, [qs, [headers,]] allback )`
  * `getUserPresence( userID_or_emailAddr, [qs, [headers,]] callback )`
  * `getUsers( [qs, [headers,]] callback )`
  * `getWorkspace( orgID, wsID, [qs, [headers,]] callback )`
  * `getWorkspaceMembers( orgID, wsID, [qs, [headers,]] callback )`
  * `getWorkspacesInOrg( orgID, [qs, [headers,]] callback )`

### Creating & Adding
  * `postFile( orgID, wsID, inputStream, [qs, [headers,]] callback )`
  * `postMessageToUser( orgID, userID_or_emailAddr, payload, [qs, [headers,]] callback )`
  * `postMessageToWorkspace( orgID, wsId, payload, [qs, [headers,]] callback )`
  * `postNote( orgID, wsID, note, [qs, [headers,]] callback )`
  * `postOrg( org, [qs, [headers,]] callback )`
  * `postOrgMember( orgID, userID_or_emailAddr, payload, [qs, [headers,]] callback )`
  * `postUser( user, [qs, [headers,]] callback )`
  * `postWorkspace( orgID, wsID, [qs, [headers,]] callback )`
  * `postWorkspaceMember( orgID, wsId, userID_or_emailAddr, payload, [qs, [headers,]] callback )`

### Updating
  * `putNote( orgID, wsID, noteID_or_noteUUID, payload, [qs, [headers,]] callback )`
  * `putOrg( orgID, payload, [qs, [headers,]] callback )`
  * `putOrgMember( orgID, userID_or_emailAddr, payload, [qs, [headers,]] callback )`
  * `putUser( userID_or_emailAddr, payload, [qs, [headers,]] callback )`
  * `putUserPresence( userID_or_emailAddr, payload, [qs, [headers,]] callback )`
  * `putWorkspace( orgID, wsID, payload, [qs, [headers,]] callback )`
  * `putWorkspaceMember( orgID, wsID, userID_or_emailAddr, payload, [qs, [headers,]] callback )`

### Destroying & Removing
  * `deleteNote( orgID, wsID, noteID_or_noteUUID, [qs, [headers,]] callback )`
  * `deleteOrg( orgID, [qs, [headers,]] callback )`
  * `deleteOrgMember( orgID, userID_or_emailAddr, [qs, [headers,]] callback )`
  * `deleteOrgs( [qs, [headers,]] callback )`
  * `deleteUser( userID_or_emailAddr, [qs, [headers,]] callback )`
  * `deleteWorkspace( orgID, wsID, [qs, [headers,]] callback )`
  * `deleteWorkspaceMember( orgID, wsID, userID_or_emailAddr, [qs, [headers,]] callback )`

### Testing & Debugging
  * `deleteEcho( [qs, [headers,]] callback )`
  * `getEcho( [qs, [headers,]] callback )`
  * `getPing( [qs, [headers,]] callback )`
  * `postEcho( body, [qs, [headers,]] callback )`
  * `putEcho( body, [qs, [headers,]] callback )`


## Arbitrary Methods

In addition to the pre-defined methods, you may execute a request against an arbitrary path (below the Intellinote REST API "base URL") using the following methods:

  * `get( path, [qs, [headers,]] callback )`
  * `put( path, body, [qs, [headers,]] callback )`
  * `post( path, body, [qs, [headers,]] callback )`
  * `patch( path, body, [qs, [headers,]] callback )`
  * `delete( path, [qs, [headers,]] callback )`
     * alternatively, `del( path, [qs, [headers,]] callback )`

For each of these methods the callback signature is identical to that of the explicit API methods, namely `callback(err, json, response, body)`.
