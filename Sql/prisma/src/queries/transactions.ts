import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * TRANSACTION & BATCH OPERATIONS
 * Demonstrates ACID transactions and batch operations
 */
export const TransactionQueries = {
  /**
   * Create user with profile in a transaction
   * @param userData - User data
   * @param bio - Profile bio
   * @returns Object containing user and profile
   * SQL Equivalent: BEGIN; INSERT User; INSERT Profile; COMMIT;
   */
  createUserWithProfileTransaction: async (
    userData: { email: string; name?: string },
    bio: string
  ) => {
    return await prisma.$transaction(async (tx) => {
      const user = await tx.user.create({
        data: userData,
      });

      const profile = await tx.profile.create({
        data: {
          bio,
          userId: user.id,
        },
      });

      return { user, profile };
    });
  },

  /**
   * Transfer post ownership with validation
   * @param postId - Post ID to transfer
   * @param fromUserId - Current owner ID
   * @param toUserId - New owner ID
   * @returns Updated post
   * SQL Equivalent: Transaction with SELECT then UPDATE
   */
  transferPostOwnership: async (
    postId: number,
    fromUserId: number,
    toUserId: number
  ) => {
    return await prisma.$transaction(async (tx) => {
      // First verify the post exists and belongs to fromUserId
      const post = await tx.post.findUnique({
        where: { id: postId },
      });

      if (!post || post.authorId !== fromUserId) {
        throw new Error(
          'Post not found or not owned by the specified current owner'
        );
      }

      // Then update the owner
      return await tx.post.update({
        where: { id: postId },
        data: { authorId: toUserId },
      });
    });
  },

  /**
   * Batch create multiple posts
   * @param posts - Array of post data
   * @returns Count of created posts
   * SQL Equivalent: INSERT INTO Post VALUES (...), (...), ...
   */
  createMultiplePosts: async (
    posts: Array<{ title: string; content?: string; authorId: number }>
  ) => {
    const result = await prisma.post.createMany({
      data: posts,
      skipDuplicates: true, // Skip if duplicates exist
    });
    return result.count;
  },

  /**
   * Batch update posts by author
   * @param authorId - Author ID
   * @param data - Data to update
   * @returns Count of updated posts
   * SQL Equivalent: UPDATE Post SET ... WHERE authorId = ?
   */
  updatePostsByAuthor: async (
    authorId: number,
    data: { published?: boolean }
  ) => {
    const result = await prisma.post.updateMany({
      where: { authorId },
      data,
    });
    return result.count;
  },

  /**
   * Delete all unpublished posts older than date
   * @param date - Cutoff date
   * @returns Count of deleted posts
   * SQL Equivalent: DELETE FROM Post WHERE published = false AND createdAt < ?
   */
  cleanupOldUnpublishedPosts: async (date: Date) => {
    const result = await prisma.post.deleteMany({
      where: {
        published: false,
        createdAt: { lt: date },
      },
    });
    return result.count;
  },
};