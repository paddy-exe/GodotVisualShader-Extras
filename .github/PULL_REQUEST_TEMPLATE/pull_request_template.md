name: Pull Request
description: Add a feature or a fix for a bug in VisualShader-Extras
body:

- type: markdown
  attributes:
    value: |
      - Write a descriptive PR (Pull Request) title above.
      - If you are creating a fix for an issue, search [open](https://github.com/paddy-exe/GodotVisualShader-Extras/issues) issues to ensure it is mentioned with the ``Fixes`` keyword for GitHub to automatically close the issue when merging the PR.

- type: textarea
  attributes:
    label: Description of the changes that were made
    placeholder: Added feature 1, 2, 3, etc.
  validations:
    required: true

- type: textarea
  attributes:
    label: Screenshots / Videos of your changes
  validations:
    required: true