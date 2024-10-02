# Development guide

## Getting started

### Configuring auto registration

You have the option to set up a static user for automatic registration on your device. This feature helps the process of targeting your devices during development across various app installations. Create a `SampleUser.plist` on the Sample App directory with the properties `userId` and `userName`



### Git hooks

To ensure correct linting, formatting, and that the commit messages are up to convention, 2 git hooks are present in the .hooks folder.
To install them, please run the following command in root folder:

```shell
git config core.hooksPath .hooks
```
