
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

### Notes

- you may need to hit the git providers via ssh to get them added to your known hosts

## TODO (so much):

### Features

- better logging and feedback
  - log all operations rather than just spitting out shell stuff
  - various log levels
  - programatically monitor git progress?
  - provide intelligible output when running concurrent threads
- tests
- make it a standalone executable that creates a working directory for you
  - where is the right place for working dir on unix?
- add providers for
  - beanstalk svn
  - generic git (pull only)
  - generic svn (pull only)
- autoloader (or at least do loading right)
- allow the name to be different on the target vs. the source
- manually override metadata
- figure out terminology (provider, service, repo)
- refactor. be always refactoring.

### Bugs

- fix issue with other users' repos on github
- allow updating of existing cloned repo

### Investigate

- implement the multi-branch stuff with refspecs rather than CLI flags
- bare repos seem like the right approach here