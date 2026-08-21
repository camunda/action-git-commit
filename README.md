# Commit & push changes

This GitHub Action commits and pushes changes which have been made by precedent
steps, if there are any changes.

This is mostly useful in the case were an automated process (like Renovate)
updates some value somewhere in the repository and another process requires to
propagate the Renovate update to multiple files (aka. "golden files").

> [!WARNING]
>
> This action will fail if there are "too many" commits (more than 3 by
> default) done by the same author using the "commit message" that would be
> used to commit the changes later on, in the opened branch.
>
> This is a protection mechanism to prevent GitHub Action to create too many
> new runs because a change was made from GitHub Action itself.
>
> To enable this protection mechanism, use the `fetch-depth: 0` option of
> `actions/checkout`.


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

In addition, if you want to detect infinite loop of GitHub Action runs triggered by git push from this action, fetch all the branches at the beginning of the workflow with the `fetch-depth: 0` option from the `actions/checkout` GitHub Action:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0 # fetch all the branches, not only the current one
```

This will fetch the current branch plus all the other branches, and allow to
detect how many commits were done by the author between the main branch and the
current one, in order to detect endless commits.


### Pushing changes on pull requests

This action pushes to whatever branch is currently checked out. For jobs
running on `pull_request` events, you need to checkout the actual name of the
branch (instead of the default "detached-HEAD checkout") using something like:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
          # Checkout the branch instead of detached HEAD, so changes can be
          # pushed back to it.
          ref: ${{ github.event.pull_request.head.ref }}
```

If the checkout uses a token from a different identity than the one that
triggered the workflow (e.g. a GitHub App token) and the head branch lives in
a fork, also pin the `repository`:

```yaml
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
          repository: ${{ github.event.pull_request.head.repo.full_name }}
          ref: ${{ github.event.pull_request.head.ref }}
          token: ${{ steps.github-auth.outputs.token }}
```

## Inputs

| Name | Required | Default | Description |
| --- | --- | --- | --- |
| `commit-message` | No | `Commit changes` | The commit message to use when changes have been detected. |
| `author-name` | No | _(none)_ | Name of the commit author. If not set, the author of the previous commit will be used. |
| `author-email` | No | _(none)_ | Email of the commit author. If not set, the author of the previous commit will be used. |
| `github-token` | No | `""` | An optional GitHub token to authenticate with GitHub. If not set, the default ambient credentials will be used. |

## Outputs

| Name | Description |
| --- | --- |
| `changes-pushed` | Whether any changes have been pushed. |

## How to use?

```yaml
steps:
  - uses: camunda/action-git-commit@v1
```

You can specify an alternative Git commit message:

```yaml
steps:
  - uses: camunda/action-git-commit@v1
    with:
      commit-message: Hey ho, here are some changes!
```

You can specify a commit author:

```yaml
steps:
  - uses: camunda/action-git-commit@v1
    with:
      commit-message: Hey ho, here are some changes!
      author-name: Bob
      author-email: bob@example.com
```

The action output a `changes-pushed` value if changes have been pushed:

```yaml
steps:
  - uses: camunda/action-git-commit@v1
    id: commit

  - if: ${{ steps.commit.outputs.changes-pushed == 'true' }}
    run: Changes have been pushed!
```

### Authentication

Instead of the default ambient git credentials, you can specify a GitHub token
to use, for example one generated for a GitHub App:

```yaml
steps:
  - uses: camunda/action-git-commit@v1
    with:
      commit-message: "test: update golden files"
      github-token: ${{ steps.auth.outputs.token }}

      # Alternatively, you can use the current workflow's GITHUB_TOKEN if it
      # has the "contents: write" permission:
      #github-token: ${{ secrets.GITHUB_TOKEN }}
```
