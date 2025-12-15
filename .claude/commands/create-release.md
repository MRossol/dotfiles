# create-release

Use the git history, existing releases, tags, and arguments to create a release on github.

- If a version is not supplied, increment the latest tag using semantic versioning based on the git history.
- If a branch is not supplied use the current branch.
- If on a branch that is not main, create a pre-release by default unless specified otherwise.
- If a pre-release is specified, create a pre-release version.
- When creating a pre-release, determine the next proper semantic version based on the git history and then add a -rc.1 suffix. Future pre-releases will increment the rc version by 1.
- Always prompt the user to confirm the version before creating the release.

## Args

- branch: The branch to create a release for
- version: The version to create a release for
- pre-release: Create a pre-release version

## Semantic Versioning

- Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) as a guide for determining the next version based on the git history.
- For releases on main use the most recent merge commit to determine the next version.
- For releases on other branches use the branch commit history to determine the next version.
