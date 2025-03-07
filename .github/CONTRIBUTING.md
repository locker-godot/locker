# Contributing Guide
Hello! Thanks for taking the time to read the contribution guideline for the
Locker framework :D

In this document you'll find information about how you can make
contributions to improve Locker, either by fixing bugs, implementing features,
or pointing out bugs or ideas.

## 🐛 Reporting Bugs
To report bugs you found in the Locker plugin, you can use this
[Github Issue template](https://github.com/locker-godot/locker/issues/new?template=bug_report.md). Please make sure to include as much information as
possible, in order to make the fixing process easier and quicker.

Before doing that, though, do search in the current
[Issues](https://github.com/locker-godot/locker/issues)
in order to know if the problem in question wasn't already reported.
If it was, you can contribute adding missing information to the existent report
through comments.

## 💡 Proposing Features
In order to propose new features, you can use this
[Github Issue template](https://github.com/locker-godot/locker/issues/new?template=feature_request.md).
Please, make sure the feature you have in mind fits the plugin's purpose and is
desirable in most use cases.

Always propose a feature before working on a Pull Request to implement it in
order to make sure it is wanted by the users and maintainers.

## 🌐 Translating the README.md
If you want to contribute with translations, you can do so creating or updating
`README.md` files of other languages inside the `READMEs` folder in the root
directory of the project.

## ✨ Creating Pull Requests
If you want to create Pull Requests with new functionality, make sure it is
desired by previously submitting an [Issue](https://github.com/locker-godot/locker/issues/new?template=feature_request.md) with a proposal.
In case a proposal for that feature already exists, read the discussion to see
if it was accepted or rejected before developing it.

For feature or fix Pull Requests, it's always best to discuss the implementation you're going to use to address them in their respective [Issues](https://github.com/locker-godot/locker/issues), in order to find out a more acceptable way to implement it.

When submitting Pull Requests, make sure that they use the `fixes #` or the
`closes #` keywords with the respective Issue number after the `#`, so that,
when accepted, they automatically close their corresponding Issue.

When writing code, always make sure to follow a similar structure as the one
already used in the existent plugin code. For most cases, the conventions are
similar to the ones used by the
[GDScript styleguides](https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_styleguide.html), but, if in doubt, try searching for places
in the codebase where similar code is written.

### Take care with commits
Try to make simple PRs that handle one specific topic. Just like for reporting issues, it's better to open 3 different PRs that each address a different Issue than one big PR with that aims at solving three problems. This makes it easier to review, approve, and merge the changes independently.

When updating your fork with upstream changes, please use git pull --rebase to avoid creating "merge commits". Those commits unnecessarily pollute the git history when coming from PRs.

When commiting, always certify that your commits are atomic, meaning that
each commit has one clear and defined purpose, described in a few words in
its title.

### Keep commit messages meaningful
The way you format your commit messages is quite important to ensure that the commit history stays easy to read and understand.

Try to keep your commit messages under 72 characters, but you can go slightly
above if necessary to keep the sentence clear.

Also, make sure the commit messages are meaningful, describing the alterations
brought by them in a concise way.

The commit messages should be written in English, with a emoji prefix and a type prefix, and with the main text part, typically starting with a verb in the past tense.
A common bugfix would start with ":bug: fix:", while the addition of a new
feature would start with ":sparkles: feat:".
A prefix can be added to specify the area of the plugin affected by the commit. Down below are some examples of commit messages:

```
:sparkles: feat: Autosaver
:books: docs: StorageManager
:bug: fix: error on loading empty partition ids
:pushpin: chore: created CONTRIBUTING guide
:wrench: env (.gitignore): ignored config.cfg
:recycle: refac: data management structure from Dict to custom class
```

Always write a clear log message for your commits. One-line messages are okay for small changes, but bigger changes can use descriptions.

### Document your changes
If your Pull Request adds or changes methods, properties, signals or classes,
you must update the documentation to cover those.

If your Pull Request modifies parts of the code in a non-obvious way, make sure
to add comments in the code as well. This helps other people understand the
change without having to dive into the Git history.

### Write unit tests
When fixing a bug or contributing to a new feature, include unit tests in the
Pull Request.

Pull Requests that include tests are more likely to be merged, since it's possible to have greater confidence that they won't easily open space for regressions in the future.

For bugs, the unit tests should cover the functionality that was previously broken. This makes it less likely that regressions appear in the future again.
For new features, the unit tests should cover the newly added functionality, testing both the "success" and "expected failure" cases if applicable.

Feel free to contribute standalone Pull Requests to add new tests or improve existing tests as well.

## 💖 Donating
If you’d like to support the creator financially to keep making and maintaining projects like this, you can do so through
[GitHub Sponsors](https://github.com/sponsors/nadjiel) or
[Ko-fi](https://ko-fi.com/nadjiel).
Your contributions help sustain development and are immensily appreciated!

---

Thank you again for reading this guide and for considering contributing to the
Locker framework! :3
