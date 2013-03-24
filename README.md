
# Reposlanger

A tool for dealing with repos spread among multiple services. The idea is to provide a CLI interface to pull from one and push to another, and to make it easy to add new services.

## TODO (so much):

- deal with the fact that the class (as well as the instance) needs access to the api, in order to get a repo list
- implement passing metadata around (things like privacy, website)
- better logging and feedback
- tests
- actually implement batch and other things that would make this useful
- make it a standalone executable that creates a working directory for you
- add beanstalk (svn and git), github, finish gitlabhq
- some way to make it so you can rename the repo when transferring
- autoloader
- work on having multiple repos from one provider
- allow the name to be different on the target vs. the source
- manually override metadata
- refactor. be always refactoring.