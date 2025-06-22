import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * AGGREGATION & ADVANCED QUERIES
 * Demonstrates aggregation functions and advanced query techniques
 */
export const AggregationQueries = {
  /**
   * Get post statistics by author
   * @returns Array of authors with post counts, avg length, etc.
   * SQL Equivalent: GROUP BY with COUNT, AVG, etc.
   */
  getPostStatsByAuthor: async () => {
    return await prisma.user.findMany({
      select: {
        id: true,
        name: true,
        email: true,
        _count: {
          select: { posts: true },
        },
      },
      orderBy: {
        posts: {
          _count: 'desc',
        },
      },
    });
  },

  /**
   * Get average post length by author
   * @returns Array of authors with average post length
   * SQL Equivalent: GROUP BY with AVG(LENGTH(content))
   */
  getAveragePostLengthByAuthor: async () => {
    // First we need to add a computed field in the schema or use raw SQL
    // This is a simplified version - for actual length you might need raw SQL
    const authors = await prisma.user.findMany({
      include: {
        posts: {
          select: {
            content: true,
          },
        },
      },
    });

    return authors.map((author) => {
      const lengths = author.posts
        .filter((post) => post.content)
        .map((post) => post.content?.length || 0);
      const avgLength =
        lengths.length > 0
          ? lengths.reduce((sum, len) => sum + len, 0) / lengths.length
          : 0;

      return {
        authorId: author.id,
        authorName: author.name,
        averagePostLength: avgLength,
        postCount: author.posts.length,
      };
    });
  },

  /**
   * Get the most popular tags (used in most posts)
   * @param limit - Number of tags to return
   * @returns Array of popular tags with post counts
   * SQL Equivalent: GROUP BY with COUNT and JOIN
   */
  getMostPopularTags: async (limit: number = 5) => {
    return await prisma.tag.findMany({
      select: {
        id: true,
        name: true,
        _count: {
          select: { posts: true },
        },
      },
      orderBy: {
        posts: {
          _count: 'desc',
        },
      },
      take: limit,
    });
  },

  /**
   * Full-text search in posts (title and content)
   * @param searchTerm - Term to search for
   * @returns Matching posts
   * SQL Equivalent: WHERE title LIKE ? OR content LIKE ?
   */
  searchPosts: async (searchTerm: string) => {
    return await prisma.post.findMany({
      where: {
        OR: [
          { title: { contains: searchTerm, mode: 'insensitive' } },
          { content: { contains: searchTerm, mode: 'insensitive' } },
        ],
      },
      orderBy: {
        _relevance: {
          fields: ['title', 'content'],
          search: searchTerm,
          sort: 'desc',
        },
      },
    });
  },

  /**
   * Get paginated posts with total count
   * @param page - Page number (1-based)
   * @param pageSize - Number of items per page
   * @returns Object with posts and total count
   * SQL Equivalent: LIMIT/OFFSET with separate COUNT query
   */
  getPaginatedPosts: async (page: number = 1, pageSize: number = 10) => {
    const skip = (page - 1) * pageSize;
    const [posts, totalCount] = await Promise.all([
      prisma.post.findMany({
        skip,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: {
          author: {
            select: {
              id: true,
              name: true,
            },
          },
        },
      }),
      prisma.post.count(),
    ]);

    return {
      data: posts,
      total: totalCount,
      page,
      pageSize,
      totalPages: Math.ceil(totalCount / pageSize),
    };
  },

  /**
   * Execute raw SQL query (for cases not covered by Prisma)
   * @param query - Raw SQL query string
   * @param params - Query parameters
   * @returns Raw query result
   */
  executeRawQuery: async (query: string, params: any[] = []) => {
    return await prisma.$queryRawUnsafe(query, ...params);
  },
};