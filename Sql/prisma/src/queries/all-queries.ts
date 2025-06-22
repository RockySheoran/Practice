import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const BasicQueries = {
  // CREATE operations
  createUser: async (data: { email: string; name?: string }) => {
    return await prisma.user.create({ data });
  },

  createPost: async (data: { title: string; content?: string; authorId: number }) => {
    return await prisma.post.create({ data });
  },

  // READ operations
  getAllUsers: async () => {
    return await prisma.user.findMany();
  },

  getUserById: async (id: number) => {
    return await prisma.user.findUnique({ where: { id } });
  },

  findUsersByName: async (name: string) => {
    return await prisma.user.findMany({ where: { name: { contains: name } } });
  },

  // UPDATE operations
  updateUser: async (id: number, data: { name?: string; email?: string }) => {
    return await prisma.user.update({ where: { id }, data });
  },

  // DELETE operations
  deleteUser: async (id: number) => {
    return await prisma.user.delete({ where: { id } });
  },
};

export const JoinQueries = {
  // INNER JOIN equivalent
  getPostsWithAuthors: async () => {
    return await prisma.post.findMany({
      include: { author: true },
    });
  },

  // LEFT JOIN equivalent
  getUsersWithPosts: async () => {
    return await prisma.user.findMany({
      include: { posts: true },
    });
  },

  // Complex join with filtering
  getPublishedPostsByAuthor: async (authorId: number) => {
    return await prisma.post.findMany({
      where: {
        authorId,
        published: true,
      },
      include: {
        author: true,
        comments: true,
      },
    });
  },
};

export const TransactionQueries = {
  createUserWithProfile: async (userData: { email: string; name?: string }, bio: string) => {
    return await prisma.$transaction(async (prisma) => {
      const user = await prisma.user.create({ data: userData });
      const profile = await prisma.profile.create({
        data: {
          bio,
          userId: user.id,
        },
      });
      return { user, profile };
    });
  },

  transferPostOwnership: async (postId: number, fromUserId: number, toUserId: number) => {
    return await prisma.$transaction(async (prisma) => {
      // Verify the post belongs to fromUserId
      const post = await prisma.post.findUnique({
        where: { id: postId },
      });

      if (!post || post.authorId !== fromUserId) {
        throw new Error('Post not found or not owned by specified user');
      }

      // Update the post's author
      return await prisma.post.update({
        where: { id: postId },
        data: { authorId: toUserId },
      });
    });
  },
};

export const AggregateQueries = {
  getPostCountByAuthor: async () => {
    return await prisma.user.findMany({
      include: {
        _count: {
          select: { posts: true },
        },
      },
    });
  },

  getAveragePostLength: async () => {
    const result = await prisma.post.aggregate({
      _avg: {
        contentLength: true,
      },
    });
    return result._avg.contentLength;
  },

  getMostActiveUsers: async (limit: number = 5) => {
    return await prisma.user.findMany({
      include: {
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
};

export const AdvancedQueries = {
  // Raw SQL when needed
  executeRawQuery: async (query: string, values: any[] = []) => {
    return await prisma.$queryRawUnsafe(query, ...values);
  },

  // Full-text search example
  searchPosts: async (searchTerm: string) => {
    return await prisma.post.findMany({
      where: {
        OR: [
          { title: { contains: searchTerm, mode: 'insensitive' } },
          { content: { contains: searchTerm, mode: 'insensitive' } },
        ],
      },
    });
  },

  // Pagination example
  getPaginatedPosts: async (page: number, pageSize: number = 10) => {
    const skip = (page - 1) * pageSize;
    return await prisma.post.findMany({
      skip,
      take: pageSize,
      orderBy: { createdAt: 'desc' },
    });
  },
};