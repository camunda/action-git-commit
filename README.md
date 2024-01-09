# Commit & push changes

This GitHub Action commits and pushes changes which have been made by precedent
steps, if there are any changes.


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
