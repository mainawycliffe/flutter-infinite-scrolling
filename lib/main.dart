import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// you need to create this file with Github Personal Token
import 'local.dart' show GITHUB_ACCESS_TOKEN;

const String getMyRepositories = r'''
  query ReadRepositories($nRepositories: Int!, $cursor: String) {
    search(last: $nRepositories, query: "flutter", type: REPOSITORY, after: $cursor) {
      nodes {
        __typename
        ... on Repository {
          nameWithOwner
          shortDescriptionHTML
          viewerHasStarred
          stargazers {
            totalCount
          }
          forks {
            totalCount
          }
          updatedAt
        }
      }
      pageInfo {
        endCursor
        hasNextPage
        hasPreviousPage
        startCursor
      }
    }
  }
  ''';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final _httpLink = HttpLink(
      uri: 'https://api.github.com/graphql',
    );

    final _authLink = AuthLink(
      getToken: () async => 'Bearer $GITHUB_ACCESS_TOKEN',
    );

    final _link = _authLink.concat(_httpLink);

    final _client = ValueNotifier(
      GraphQLClient(
        cache: InMemoryCache(),
        link: _link,
      ),
    );

    return MaterialApp(
      title: 'Infine Scrolling Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GraphQLProvider(
        client: _client,
        child: MyHomePage(title: 'Infinite Scrolling Demo'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final nRepositories = 10;

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Query(
              options: QueryOptions(
                document: getMyRepositories,
                variables: <String, dynamic>{
                  'nRepositories': nRepositories,
                  // set cursor to null so as to start at the beginning
                  // 'cursor': 10
                },
              ),
              builder: (QueryResult result, {refetch, FetchMore fetchMore}) {
                if (result.loading && result.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (result.hasErrors) {
                  return Text('\nErrors: \n  ' + result.errors.join(',\n  '));
                }

                if (result.data == null && result.errors == null) {
                  return const Text(
                      'Both data and errors are null, this is a known bug after refactoring, you might forget to set Github token');
                }

                final List<dynamic> repositories =
                    (result.data['search']['nodes'] as List<dynamic>);

                final Map pageInfo = result.data['search']['pageInfo'];
                final String fetchMoreCursor = pageInfo['endCursor'];
                FetchMoreOptions opts = FetchMoreOptions(
                  variables: {'cursor': fetchMoreCursor},
                  updateQuery: (previousResultData, fetchMoreResultData) {
                    // this is where you combine your previous data and response
                    // in this case, we want to display previous repos plus next repos
                    // so, we combine data in both into a single list of repos
                    final List<dynamic> repos = [
                      ...previousResultData['search']['nodes'] as List<dynamic>,
                      ...fetchMoreResultData['search']['nodes'] as List<dynamic>
                    ];

                    fetchMoreResultData['search']['nodes'] = repos;

                    return fetchMoreResultData;
                  },
                );

                return Expanded(
                  child: ListView(
                    children: <Widget>[
                      for (var repository in repositories)
                        ListTile(
                          leading: (repository['viewerHasStarred'] as bool)
                              ? const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                )
                              : const Icon(Icons.star_border),
                          title: Text(repository['nameWithOwner'] as String),
                        ),
                      if (result.loading)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(),
                          ],
                        ),
                      RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Load More"),
                          ],
                        ),
                        onPressed: () {
                          fetchMore(opts);
                        },
                      )
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
