import { 
  BasicQueries, 
  JoinQueries, 
  TransactionQueries, 
  AggregateQueries, 
  AdvancedQueries 
} from './queries/all-queries';

async function main() {
  // Basic CRUD examples
  const newUser = await BasicQueries.createUser({
    email: 'alice@example.com',
    name: 'Alice',
  });
  console.log('Created user:', newUser);

  // Join examples
  const postsWithAuthors = await JoinQueries.getPostsWithAuthors();
  console.log('Posts with authors:', postsWithAuthors);

  // Transaction example
  const userWithProfile = await TransactionQueries.createUserWithProfile(
    { email: 'bob@example.com', name: 'Bob' },
    'I love SQL!'
  );
  console.log('User with profile:', userWithProfile);

  // Aggregate example
  const postCounts = await AggregateQueries.getPostCountByAuthor();
  console.log('Post counts by author:', postCounts);

  // Advanced example
  const searchResults = await AdvancedQueries.searchPosts('database');
  console.log('Search results:', searchResults);
}

// main()
//   .catch((e) => {
//     console.error(e);
//     process.exit(1);
//   })
//   .finally(async () => {
//     await prisma.$disconnect();
//   });