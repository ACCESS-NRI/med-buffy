Configuration
=============

Buffy is configured using a simple YAML file containing all the settings needed. The settings file is located in the `/config` dir and is named `settings-<environment>.yml`, where `<environment>` is the name of the environment Buffy is running in, usually set via the *RACK_ENV* env var. So for a Buffy instance running in production mode, the configuration file will be `/config/settings-production.yml`

A sample settings file will look similar to this:

```yaml
buffy:
  bot_github_user: <%= ENV['BUFFY_BOT_GH_USER'] %>
  gh_access_token: <%= ENV['BUFFY_GH_ACCESS_TOKEN'] %>
  gh_secret_token: <%= ENV['BUFFY_GH_SECRET_TOKEN'] %>
  teams:
    editors: 3824115
    eics: myorg/editor-in-chief-team
  responders:
    help:
    hello:
      hidden: true
    assign_reviewer_n:
      only: editors
    remove_reviewer_n:
      only: editors
      no_reviewer_text: "TBD"
    assign_editor:
      only: editors
    remove_editor:
      only: editors
      no_editor_text: "TBD"
    invite:
      only: eics
    set_value:
      - version:
          only: editors
          sample_value: "v1.0.0"
      - archive:
          only: editors
          sample_value: "10.21105/joss.12345"
    welcome:
```

## Available settings

The structure of the settings file starts with a single root node called `buffy`.
It contains three main parts:

  - A few simple key/value settings
  - The `teams` node
  - The `responders` node

A detailed description of all of them:

### General configuration options

<dl>
  <dt>bot_github_user</dt>
  <dd>The name of the bot. It is the GitHub user that will respond to commands. It should have admin permissions on the reviews repo.</dd>

  <dt>gh_access_token</dt>
  <dd>The GitHub developer access token for the bot user.</dd>

  <dt>gh_secret_token</dt>
  <dd>The GitHub secret token configured for the webhook sending events to Buffy.</dd>
</dl>

### Teams

```yaml
  teams:
    editors: 3824117
    eics: myorg/editor-in-chief-team
    reviewers: 45363564
```
 The teams node includes entries to reference GitHub teams, used later to grant access to responders only to users belonging to specific teams. Multiple entries can added to the teams node. All entries follow this simple format:

 <dl>
  <dt>key: value</dt>
  <dd>Where <em>key</em> is the name for this team in Buffy and <em>value</em> can be the integer id of the team in GitHub (preferred) or the reference in format <em>organization/name</em> (for example: <em>openjournals/editors</em>)</dd>
</dl>

### Responders

```yaml
  responders:
    help:
    hello:
      hidden: true
    assign_reviewers:
      only: editors
```

 The responders node lists all the responders that will be available. The key for each entry is the name of the responder and nested under it the configuration options for that responder are declared.

 All the responders share some options available for all of them. They also can have their own particular configurable parameters (see docs for each responder). The common parameters are:

<dl>
  <dt>hidden</dt>
  <dd>Defaults to <em>false</em>. If <em>true</em> this responder won't be listed in the help provided to users.</dd>

  <dt>only</dt>
  <dd>List of teams (refered by the name used in the <em>teams</em> node) that can have access to the responder. Used to limit access to the responder. If <em>only</em> is not present the responder is considered public and every user in the repository can invoke it.

  Example:

  ```yaml
    public_responder:
    available_for_one_team_responder:
      only: editors
    available_for_two_teams_responder:
      only:
        - editors
        - reviewers
  ```

  </dd>
</dl>

#### Multiple instances of the same responder

Sometimes you want to use a responder more than once, with different parameters. In that case under the name of the responder you can declare an array of instances, and the key for each instance will be passed to the responder as the `name` parameter.

Example:

The _set_value_ responder uses a `name` param to change the value to a variable. If declared in the settings file like this:


```yaml
  responders:
    set_value:
      name: version
```

It could be invoked with `@botname set 1.0 as version`.

If you want to use the same responder to change `version` but also to allow editors to change `url` you would declare multiple instances in the settings file like this:

```yaml
  responders:
    set_value:
      - version:
      - archive:
          only: editors
```

Now `@botname set 1.0 as version` is a public command and `@botname set abcd.efg as url` is a command available to editors.

