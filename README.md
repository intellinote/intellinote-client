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

> NOTE: You can obtain a list of API methods supported by Intellinote Client by running `node intellinote.js` and including the parameter `--by-path` to get a list of API functions indexed by REST endpoint or `--by-method` to get a list of REST endpoints listed by API function.

### Generic HTTP Methods

In addition to the pre-defined methods list below, you may execute a request against an arbitrary path (below the Intellinote REST API "base URL") using the following methods:

  * `get( path, [qs, [headers,]] callback )`
  * `put( path, body, [qs, [headers,]] callback )`
  * `post( path, body, [qs, [headers,]] callback )`
  * `patch( path, body, [qs, [headers,]] callback )`
  * `delete( path, [qs, [headers,]] callback )`
     * alternatively, `del( path, [qs, [headers,]] callback )`

For each of these methods the callback signature is identical to that of the explicit API methods, namely `callback(err, json, response, body)`.

### Pre-Defined Methods

The following is a list of Intellinote REST API methods that are supported as functions in the Intellinote Client.

The REST method and path are listed first, followed by the corresponding Intellinote Client function.  Note that each REST endpoint is made available under several aliases (all of which are listed here).  Each of these aliased methods are equivalent, it's just one method with several names.

See [the Intellinote REST API documentation](https://app.intellinote.net/rest/api/v2/) for more information about these endpoints.

#### Ping and Echo
- **`GET    /ping`** &mdash; `getPing`, `get_ping`
- **`GET    /echo`** &mdash; `getEcho`, `get_echo`
- **`POST   /echo`** &mdash; `postEcho`, `post_echo`
- **`PATCH  /echo`** &mdash; `patchEcho`, `patch_echo`
- **`PUT    /echo`** &mdash; `putEcho`, `put_echo`
- **`DELETE /echo`** &mdash; `deleteEcho`, `delete_echo`

#### Users
- **`GET    /user/{0}`** &mdash; `getUser`, `get_user`
- **`GET    /user/{0}/presence`** &mdash; `getUserPresence`, `get_user_presence`
- **`GET    /user/email/{0}/available`** &mdash; `getEmailAvailable`, `getUserEmailAvailable`, `get_email_available`, `get_user_email_available`
- **`GET    /users`** &mdash; `getUsers`, `get_users`
- **`GET    /users/dt`** &mdash; `getUsersDT`, `get_users_dt`
- **`POST   /user`** &mdash; `postUser`, `post_user`
- **`PUT    /user/{0}`** &mdash; `putUser`, `put_user`
- **`PUT    /user/-/presence`** &mdash; `putUserPresence`, `put_user_presence`
- **`DELETE /user/{0}`** &mdash; `deleteUser`, `delete_user`

#### Organizations
- **`GET    /orgs`** &mdash; `getOrgs`, `get_orgs`
- **`GET    /org/{0}`** &mdash; `getOrg`, `get_org`
- **`POST   /org`** &mdash; `postOrg`, `post_org`
- **`PUT    /org/{0}`** &mdash; `putOrg`, `put_org`
- **`DELETE /org/{0}`** &mdash; `deleteOrg`, `delete_org`

#### Organization Members
- **`GET    /org/{0}/members`** &mdash; `getOrgMembers`, `get_org_members`
- **`GET    /org/{0}/members/count`** &mdash; `getOrgMemberCount`, `getOrgMembersCount`, `get_org_member_count`, `get_org_members_count`
- **`POST   /org/{0}/member/{1}`** &mdash; `postOrgMember`, `post_org_member`
- **`PUT    /org/{0}/member/{1}`** &mdash; `putOrgMember`, `put_org_member`
- **`DELETE /org/{0}/member/{1}`** &mdash; `deleteOrgMember`, `delete_org_member`

#### Workspaces
- **`GET    /workspaces`** &mdash; `getWorkspaces`, `get_workspaces`
- **`GET    /org/{0}/workspace/{1}`** &mdash; `getWorkspace`, `get_workspace`
- **`GET    /org/{0}/workspaces`** &mdash; `getWorkspacesInOrg`, `get_workspaces_in_org`
- **`POST   /org/{0}/workspace`** &mdash; `postWorkspace`, `post_workspace`
- **`PUT    /org/{0}/workspace/{1}`** &mdash; `putWorkspace`, `put_workspace`
- **`DELETE /org/{0}/workspace/{1}`** &mdash; `deleteWorkspace`, `delete_workspace`

#### Workspace Members
- **`GET    /org/{0}/workspace/{1}/members`** &mdash; `getWorkspaceMembers`, `get_workspace_members`
- **`POST   /org/{0}/workspace/{1}/member/{2}`** &mdash; `postWorkspaceMember`, `post_workspace_member`
- **`PUT    /org/{0}/workspace/{1}/member/{2}`** &mdash; `putWorkspaceMember`, `put_workspace_member`
- **`DELETE /org/{0}/workspace/{1}/member/{2}`** &mdash; `deleteWorkspaceMember`, `delete_workspace_member`

#### Notes (and Tasks, Files, etc.)
- **`GET    /notes`** &mdash; `getNotes`, `get_notes`
- **`GET    /note/{0}`** &mdash; `getNote`, `get_note`
- **`POST   /org/{0}/workspace/{1}/note`** &mdash; `postNote`, `post_note`
- **`PUT    /org/{0}/workspace/{1}/note/{2}`** &mdash; `putNote`, `put_note`
- **`DELETE /org/{0}/workspace/{1}/note/{2}`** &mdash; `deleteNote`, `delete_note`
- **`POST /org/{0}/workspace/{1}/file`** &mdash; `postFile`, `post_file` &ndash; note that `postFile` is a special case. It's method signature is
    `( orgID, wsID, inputStream, [qs, [headers,]] callback )` where `inputStream` is a readable stream containing the data to be uploaded.

#### Relations (Note-to-Note links)
- **`POST   /relation`** &mdash; `postRelation`, `post_relation`
- **`DELETE /relation/{0}`** &mdash; `deleteRelation`, `delete_relation`

#### Tags
- **`GET    /org/{0}/workspace/{1}/tag/{2}`** &mdash; `getTagByID`, `getTagById`, `get_tag_by_id`
- **`GET    /org/{0}/workspace/{1}/tag`** &mdash; `getTag`, `get_tag`
- **`GET    /org/{0}/workspace/{1}/tags`** &mdash; `getTags`, `get_tags`
- **`PUT    /org/{0}/workspace/{1}/tag/{2}`** &mdash; `putTag`, `put_tag`
- **`POST   /org/{0}/workspace/{1}/note/{2}/tag/{3}`** &mdash; `addTagToNote`, `add_tag_to_note`, `postNoteTag`, `postTagToNote`, `post_note_tag`, `post_tag_to_note`, `tagNote`, `tag_note`
- **`POST   /org/{0}/workspace/{1}/note/{2}/tags`** &mdash; `addTagsToNote`, `add_tags_to_note`, `multiTagNote`, `multi_tag_note`, `postNoteTags`, `postTagsToNote`, `post_note_tags`, `post_tags_to_note`
- **`DELETE /org/{0}/workspace/{1}/note/{2}/tag/{3}`** &mdash; `deleteNoteTag`, `deleteTagFromNote`, `delete_note_tag`, `delete_tag_from_note`, `removeTagFromNote`, `remove_tag_from_note`, `untagNote`, `untag_note`
- **`DELETE /org/{0}/workspace/{1}/note/{2}/tags`** &mdash; `deleteNoteTags`, `deleteTagsFromNote`, `delete_note_tags`, `delete_tags_from_note`, `multiUntagNote`, `multi_untag_note`, `removeTagsFromNote`, `remove_tags_from_note`
- **`PUT /org/{0}/workspace/{1}/note/{2}/tags`** &mdash; `overwriteNoteTags`, `overwriteTagsForNote`, `overwrite_note_tags`, `overwrite_tags_for_note`, `putNoteTags`, `put_note_tags`, `setNoteTags`, `setTagsForNote`, `set_note_tags`, `set_tags_for_note`

#### Chat Messages
- **`GET    /org/{0}/chats`** &mdash; `getOrgChats`, `get_org_chats`
- **`GET    /org/{0}/chats/new/count`** &mdash; `getNewChatCount`, `getNewChatsCount`, `get_new_chat_count`, `get_new_chats_count`
- **`POST   /org/{0}/workspace/{1}/message`** &mdash; `postChat`, `postChatToWorkspace`, `postMessage`, `postMessageToWorkspace`, `postWorkspaceChat`, `postWorkspaceMessage`, `post_chat`, `post_chat_to_workspace`, `post_message`, `post_message_to_workspace`, `post_workspace_chat`, `post_workspace_message`
- **`POST   /org/{0}/user/{1}/message`** &mdash; `postChatToUser`, `postDM`, `postDirectMessage`, `postMessageToUser`, `postUserChat`, `postUserMessage`, `post_chat_to_user`, `post_direct_message`, `post_dm`, `post_message_to_user`, `post_user_chat`, `post_user_message`

#### RTM API
- **`GET    /rtms/start`** &mdash; `getRTMSStart`, `getRTMStart`, `getRtmStart`, `getRtmsStart`, `get_rtm_start`, `get_rtms_start`, `startRTM`, `startRTMS`, `startRTMSession`, `startRtm`, `startRtmSession`, `startRtms`, `start_rtm`, `start_rtm_session`, `start_rtms`
