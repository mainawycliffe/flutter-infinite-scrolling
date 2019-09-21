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
