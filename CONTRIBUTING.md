# How to contribute

Take a look at the [Issues](https://github.com/phoenixframework/phoenix/issues)
and see if you can help out with any of them. If you have found a bug or
have a feature in mind, create a [New Issue](https://github.com/phoenixframework/phoenix/issues/new)
for it.

## Getting Started

* Make sure you have a [GitHub account](https://github.com/signup/free)
* Fork this repository on GitHub

## Making Changes

* Create a topic branch or work work from your master branch
  * This is usually the master branch.
  * To quickly create a topic branch based on master; `git checkout -b
    fix/master/my_contribution master`. Please avoid working directly on the
    `master` branch.
* Make commits of logical units.
* Check for unnecessary whitespace with `git diff --check` before committing.
* Make sure your commit messages are in the proper format.

````
    (Issue Number) Changes to CONTRIBUTING.md

    This is a sample commit message body
````

* Make sure you have added the necessary tests for your changes.
* Run _all_ the tests to assure nothing else was accidentally broken.

## Submitting Changes

* Push your changes to a topic branch in your fork of the repository.
* Submit a pull request to the repository
* When submitting Pull Request that fixes an Issue, enter the following text in 
  the Pull Request comment `Fixes #1234`. This will automatically close the Issue
  when the code is merged.
* The core team looks at Pull Requests on a regular basis
* After feedback has been given we expect responses within two weeks. After two
  weeks will may close the pull request if it isn't showing any activity.

# Additional Resources

* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
