
# Reposlanger

A tool for dealing with repos spread among multiple services. The idea is to provide a CLI interface to pull from one and push to another, and to make it easy to add new services.

## TODO (so much):

### Features

- deal with the fact that the class (as well as the instance) needs access to the api, in order to get a repo list
- better logging and feedback
  - log all operations rather than just spitting out shell stuff
  - various log levels
  - programatically monitor git progress?
  - provide intelligible output when multithreading
- implement the multi-branch stuff with refspecs rather than CLI flags
- bare repos seem like the right approach here
- tests
- make it a standalone executable that creates a working directory for you
- add beanstalk (svn and git)
- some way to make it so you can rename the repo when transferring
- autoloader (or at least do loading right)
- allow the name to be different on the target vs. the source
- manually override metadata
- repos should not be instances of provider. provider instances should point to a particular github account
- refactor so you can have more than one service per provider
- task to list providers
- decouple API clients from providers
- figure out my damn terminology (provider, service, repo)
- refactor. be always refactoring.

### Bugs

- what happens with a half-done repo?
- what happens with a repo that's already there, but master is out of date?
-