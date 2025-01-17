# Contribution Guidelines

## Introduction

This document explains how to contribute to the RetroMeet core project.

These contribution guidelines were adapted from / inspired by those of Gitea (https://github.com/go-gitea/gitea/blob/main/CONTRIBUTING.md). Thanks Gitea!

## Issues

### How to report issues

Please search the issues on the issue tracker with a variety of related keywords to ensure that your issue has not already been reported.

If your issue has not been reported yet, [open an issue](https://github.com/retromeet/core/issues/new)
and answer the questions so we can understand and reproduce the problematic behavior. \
Please write clear and concise instructions so that we can reproduce the behavior — even if it seems obvious. \
The more detailed and specific you are, the faster we can fix the issue. \
It would be really helpful if you could reproduce your problem on a site running on the latest commits, as perhaps your problem has already been fixed on a current version. \
Please follow the guidelines described in [How to Report Bugs Effectively](http://www.chiark.greenend.org.uk/~sgtatham/bugs.html) for your report.

Please be kind when creating a bug report.

### Types of issues

Typically, issues fall into one of the following categories:

- `bug`: Something in the API behaves unexpectedly
- `security issue`: bug that has serious implications such as leaking another users' data. Please do not file such issues on the public tracker and send a mail to security@retromeet.social instead
- `feature`: Completely new functionality. You should describe this feature in enough detail that anyone who reads the issue can understand how it is supposed to be implemented
- `enhancement`: An existing feature should get an upgrade
- `refactoring`: Parts of the code base don't conform with other parts and should be changed to improve RetroMeet's maintainability

If you are not sure something belongs in the project, you can start a [discussion](https://github.com/retromeet/core/discussions) to solve any doubts you might have.

Support requests (questions on how to run RetroMeet, how to deploy it, etc) belong in the [discussions](https://github.com/retromeet/core/discussions) and not in the issues.

### Discuss your design before the implementation

We welcome submissions. \
If you want to change or add something, please let everyone know what you're working on — [file an issue](https://github.com/retromeet/core/issues/new) or comment on an existing one before starting your work!

Significant changes such as new features must go through the change proposal process before they can be accepted. \
This is mainly to save yourself the trouble of implementing it, only to find out that your proposed implementation has some potential problems. \
Furthermore, this process gives everyone a chance to validate the design, helps prevent duplication of effort, and ensures that the idea fits inside
the goals for the project and tools.

Pull requests should not be the place for architecture discussions.

### Issue locking

Commenting on closed or merged issues/PRs is strongly discouraged.
Such comments will likely be overlooked as some maintainers may not view notifications on closed issues, thinking that the item is resolved.
As such, commenting on closed/merged issues/PRs may be disabled prior to the scheduled auto-locking if a discussion starts or if unrelated comments are posted.
If further discussion is needed, we encourage you to open a new issue instead and we recommend linking to the issue/PR in question for context.

## Running Retromeet

See the [development setup instructions](https://github.com/retromeet/core/blob/main/README.md#setup).

## Dependencies

Ruby dependencies are managed using [Bundler](https://bundler.io/). \
You can find more details in the [Bundler docs](https://bundler.io/docs.html).

Pull requests should only modify `Gemfile` and `Gemfile.lock` where it is related to your change, be it a bugfix or a new feature. \
Apart from that, these files should only be modified by Pull Requests whose only purpose is to update dependencies.

The `Gemfile`, `Gemfile.lock` update needs to be justified as part of the PR description,
and must be verified by the reviewers and/or merger to always reference
an existing upstream commit.

## Styleguide

We use Rubocop for linting. To make your experience easier, it's recommended that you enable rubocop in your IDE, depending on your IDE the way to do that might be different, but most of the Ruby Language servers support rubocop, so you should be able to enable it whether you're using NeoVim, VScode or some other editor.

There's a pronto GitHub action running on each pull request that will comment on any forgotten lint issues. You can also get ahead of it by enabling lefthook, you can do it by running locally: `lefthook install --force`. The `--force` is optional, but will override any other hooks you have in this repo only, so it should be safe to run. This will run pronto any time you try to push a branch.

When contributing, you are welcome to fix pre-existing lint issues in files. But open a separate pull request for fixing up linting issues that are not related to the code you are touching, to simplify the reviewing process.

### Breaking PRs

#### What is a breaking PR?

A PR is breaking if it meets one of the following criteria:

- It changes API output in an incompatible way for existing users
- An admin must do something manually to restore the old behavior

In particular, this means that adding new settings is not breaking.\
Changing the default value of a setting or replacing the setting with another one is breaking, however.

#### How to handle breaking PRs?

If your PR has a breaking change, you must add two things to the summary of your PR:

1. A reasoning why this breaking change is necessary
2. A `BREAKING` section explaining in simple terms (understandable for a typical user) how this PR affects users and how to mitigate these changes. This section can look for example like

```md
## :warning: BREAKING :warning:
```

Breaking PRs will not be merged as long as not both of these requirements are met.
