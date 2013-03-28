
# Reposlanger

A tool for dealing with repos spread among multiple services. The idea is to provide a CLI interface to pull from one and push to another, and to make it easy to add new services.

Useful for:

- Migrating a bunch of repositories from on service to another. eg

  `thor rs:mirror_batch beanstalk github`

- Archiving old repositories so they don't count against your limit

  `thor rs:mirror myproject github bitbucket`

- Periodic offline backup of all your repos

  `thor rs:mirror myproject github gitlabhq`

## Usage

```bash
git clone git@github.com:dleavitt/reposlanger.git
cd reposlanger
bundle install
cp config.sample.toml config.toml
vim config.toml # open config.toml and add logins for your services
thor -T # list commands
thor help COMMAND # usage for an individual command
```

## TODO (so much):

### Features

- better logging and feedback
  - log all operations rather than just spitting out shell stuff
  - various log levels
  - programatically monitor git progress?
  - provide intelligible output when running concurrent threads
- tests
- make it a standalone executable that creates a working directory for you
- add beanstalk (svn and git)
- some way to make it so you can rename the repo when transferring
- autoloader (or at least do loading right)
- allow the name to be different on the target vs. the source
- manually override metadata
- decouple API clients from providers
- figure out my damn terminology (provider, service, repo)
- refactor. be always refactoring.

### Bugs

- fix issue with other users' repos on github
- allow updating of existing cloned repo

### Investigate

- implement the multi-branch stuff with refspecs rather than CLI flags
- bare repos seem like the right approach here