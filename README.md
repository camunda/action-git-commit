# Commit & push changes

This GitHub Action commits and pushes changes which have been made by precedent
steps, if there are any changes.

This is mostly useful in the case were an automated process (like Renovate)
updates some value somewhere in the repository and another process requires to
propagate the Renovate update to multiple files (aka. "golden files").

> ![WARNING]
>
> This action will fail if there are "too many" commits (more than 3 by
> default) done by the same author in the opened branch.
>
> This is a protection mechanism to prevent GitHub Action to create too many
> new runs because a change was made from GitHub Action itself.


# Pre-requisites

Your job needs to have the permission to push in the repository:

```yaml
jobs:
  something:
    runs-on: ubuntu-latest
    name: Something

    permissions:
      contents: write
```


## How to use?

```yaml
steps:
  - uses: camunda-cloud/action-git-commit@v1
```

You can specify an alternative Git commit message:

```yaml
steps:
  - uses: camunda-cloud/action-git-commit@v1
    with:
      commit-message: Hey ho, here are some changes!
```

The action output a `changes-pushed` value if changes have been pushed:

```yaml
steps:
  - uses: camunda-cloud/action-git-commit@v1
    id: commit

  - if: ${{ steps.commit.outputs.changes-pushed == 'true' }}
    run: Changes have been pushed!
```
