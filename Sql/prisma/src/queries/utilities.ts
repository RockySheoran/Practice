import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * UTILITY QUERIES
 * Helpful utility functions for database operations
 */
export const UtilityQueries = {
  /**
   * Truncate all tables (reset database)
   * WARNING: This will delete all data!
   * @returns Object with operation results
   */
  resetDatabase: async () => {
    return await prisma.$transaction([
      prisma.comment.deleteMany(),
      prisma.post.deleteMany(),
      prisma.profile.deleteMany(),
      prisma.user.deleteMany(),
      prisma.tag.deleteMany(),
    ]);
  },

  /**
   * Seed database with sample data
   * @returns Object with created records
   */
  seedDatabase: async () => {
    // Delete existing data first
    await UtilityQueries.resetDatabase();

    // Create sample users
    const user1 = await prisma.user.create({
      data: {
        email: 'alice@example.com',
        name: 'Alice',
        profile: {
          create: {
            bio: 'I love databases!',
          },
        },
      },
    });

    const user2 = await prisma.user.create({
      data: {
        email: 'bob@example.com',
        name: 'Bob',
        profile: {
          create: {
            bio: 'SQL enthusiast',
          },
        },
      },
    });

    // Create some tags
    const [dbTag, webTag, mobileTag] = await Promise.all([
      prisma.tag.create({ data: { name: 'database' } }),
      prisma.tag.create({ data: { name: 'web' } }),
      prisma.tag.create({ data: { name: 'mobile' } }),
    ]);

    // Create sample posts
    const post1 = await prisma.post.create({
      data: {
        title: 'Introduction to SQL',
        content: 'SQL is a powerful language for managing relational databases...',
        authorId: user1.id,
        published: true,
        tags: {
          connect: [{ id: dbTag.id }],
        },
      },
    });

    const post2 = await prisma.post.create({
      data: {
        title: 'Advanced Prisma Techniques',
        content: 'Prisma provides many advanced features for working with databases...',
        authorId: user2.id,
        published: true,
        tags: {
          connect: [{ id: dbTag.id }, { id: webTag.id }],
        },
      },
    });

    // Create some comments
    await Promise.all([
      prisma.comment.create({
        data: {
          content: 'Great introduction!',
          postId: post1.id,
        },
      }),
      prisma.comment.create({
        data: {
          content: 'Looking forward to more content like this',
          postId: post1.id,
        },
      }),
    ]);

    return {
      users: [user1, user2],
      posts: [post1, post2],
      tags: [dbTag, webTag, mobileTag],
    };
  },

  /**
   * Check database connection
   * @returns Boolean indicating connection status
   */
  checkDatabaseConnection: async () => {
    try {
      await prisma.$queryRaw`SELECT 1`;
      return true;
    } catch (error) {
      return false;
    }
  },

  /**
   * Get database metadata (tables, columns, etc.)
   * @returns Database metadata
   * Note: Implementation varies by database provider
   */
  getDatabaseMetadata: async () => {
    // This is PostgreSQL-specific - adjust for your database
    const tables = await prisma.$queryRaw`
      SELECT table_name, table_type 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
    `;

    const columns = await prisma.$queryRaw`
      SELECT table_name, column_name, data_type 
      FROM information_schema.columns 
      WHERE table_schema = 'public'
    `;

    return {
      tables,
      columns,
    };
  },
};