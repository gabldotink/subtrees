---
title: Recoil Relay 0.1
---

Initial open source release for the [`recoil-relay`](/docs/recoil-relay/introduction) library for using **GraphQL**!

This library helps Recoil perform type safe and efficient queries using [GraphQL](https://graphql.org/) with the [Relay](https://relay.dev) library.  It provides selectors which can easily query with GraphQL.  The queries are synced with the Recoil data-flow graph so downstream selectors can derive state from them, they can depend on upstream Recoil state, and they are automatically subscribed to any changes in the graph from Relay.  Everything stays in sync automatically.

### Example
A GraphQL query is as simple as defining a [GraphQL selector](/docs/recoil-relay/graphql-queries):

```jsx
const userNameQuery = graphQLSelector({
  key: 'UserName',
  environment: myEnvironment,
  query: graphql`
    query UserQuery($id: ID!) {
      user(id: $id) {
        name
      }
    }
  `,
  variables: ({get}) => ({id: get(currentIDAtom)}),
  mapResponse: data => data.user?.name,
});
```
Then use it like any other Recoil [selector](/docs/introduction/core-concepts#selectors):
```jsx
function MyComponent() {
  const userName = useRecoilValue(userNameQuery);
  return <span>{userName}</span>;
}
```
