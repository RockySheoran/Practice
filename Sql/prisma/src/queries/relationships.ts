import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * RELATIONSHIP & JOIN OPERATIONS
 * Demonstrates various relationship types and join operations
 */
export const RelationshipQueries = {
  /**
   * Create a post with an author (1-to-many relationship)
   * @param data - Post data including authorId
   * @returns Created post with author information
   * SQL Equivalent: INSERT INTO Post + JOIN with User
   */
  createPostWithAuthor: async (data: {
    title: string;
    content?: string;
    authorId: number;
  }) => {
    return await prisma.post.create({
      data,
      include: {
        author: true, // Include author information in the result
      },
    });
  },

  /**
   * Get all posts with their authors (INNER JOIN equivalent)
   * @returns Array of posts with author information
   * SQL Equivalent: SELECT * FROM Post INNER JOIN User ON Post.authorId = User.id
   */
  getPostsWithAuthors: async () => {
    return await prisma.post.findMany({
      include: {
        author: true,
      },
    });
  },

  /**
   * Get all users with their posts (LEFT JOIN equivalent)
   * @returns Array of users with their posts
   * SQL Equivalent: SELECT * FROM User LEFT JOIN Post ON User.id = Post.authorId
   */
  getUsersWithPosts: async () => {
    return await prisma.user.findMany({
      include: {
        posts: true,
      },
    });
  },

  /**
   * Create a user with a profile (1-to-1 relationship)
   * @param userData - User data
   * @param bio - Profile bio
   * @returns Created user with profile
   * SQL Equivalent: INSERT INTO User + INSERT INTO Profile in transaction
   */
  createUserWithProfile: async (
    userData: { email: string; name?: string },
    bio: string
  ) => {
    return await prisma.user.create({
      data: {
        ...userData,
        profile: {
          create: {
            bio,
          },
        },
      },
      include: {
        profile: true,
      },
    });
  },

  /**
   * Get posts with their tags (many-to-many relationship)
   * @returns Array of posts with their tags
   * SQL Equivalent: SELECT through join table PostTags
   */
  getPostsWithTags: async () => {
    return await prisma.post.findMany({
      include: {
        tags: true,
      },
    });
  },

  /**
   * Add a tag to a post (many-to-many relationship)
   * @param postId - Post ID
   * @param tagId - Tag ID
   * @returns Updated post with tags
   * SQL Equivalent: INSERT INTO PostTags (postId, tagId)
   */
  addTagToPost: async (postId: number, tagId: number) => {
    return await prisma.post.update({
      where: { id: postId },
      data: {
        tags: {
          connect: { id: tagId },
        },
      },
      include: {
        tags: true,
      },
    });
  },

  /**
   * Get posts with comments count (aggregation with relation)
   * @returns Array of posts with comments count
   * SQL Equivalent: SELECT Post.*, COUNT(Comment.id) FROM Post LEFT JOIN Comment...
   */
  getPostsWithCommentsCount: async () => {
    return await prisma.post.findMany({
      include: {
        _count: {
          select: { comments: true },
        },
      },
    });
  },
};