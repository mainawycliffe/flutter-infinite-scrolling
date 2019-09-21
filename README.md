# Flutter - Infinite Scrolling

This a demo for an infinite scrolling list in Flutter. The Demo uses Github GraphQL API to search for Flutter repositories, loading 25 at a time.

!["demo"]("demo.gif")

## Running this Demo

First, you will need to create a `local.dart` file, inside your `lib` directory. Inside the file, add the following:

```dart
const String GITHUB_ACCESS_TOKEN = '<PERSONAL_ACCESS_TOKEN>';
```

You can learn how to get your Github Personal Access Token (here)<https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line>.
