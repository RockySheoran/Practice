import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * BASIC CRUD OPERATIONS
 * These demonstrate fundamental Create, Read, Update, Delete operations
 */
export const BasicCRUD = {
  /**
   * Create a new user
   * @param data - User data including email and optional name
   * @returns The created user
   * SQL Equivalent: INSERT INTO User (email, name) VALUES (?, ?)
   */
  createUser: async (data: { email: string; name?: string }) => {
    return await prisma.user.create({
      data,
    });
  },

  /**
   * Get all users with optional pagination
   * @param skip - Number of records to skip (for pagination)
   * @param take - Number of records to take (for pagination)
   * @returns Array of users
   * SQL Equivalent: SELECT * FROM User LIMIT ? OFFSET ?
   */
  getAllUsers: async (skip: number = 0, take: number = 10) => {
    return await prisma.user.findMany({
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    });
  },

  /**
   * Get a single user by ID
   * @param id - User ID
   * @returns User or null if not found
   * SQL Equivalent: SELECT * FROM User WHERE id = ? LIMIT 1
   */
  getUserById: async (id: number) => {
    return await prisma.user.findUnique({
      where: { id },
    });
  },

  /**
   * Update user information
   * @param id - User ID to update
   * @param data - Data to update (name and/or email)
   * @returns Updated user
   * SQL Equivalent: UPDATE User SET name = ?, email = ? WHERE id = ?
   */
  updateUser: async (id: number, data: { name?: string; email?: string }) => {
    return await prisma.user.update({
      where: { id },
      data,
    });
  },

  /**
   * Delete a user by ID
   * @param id - User ID to delete
   * @returns Deleted user
   * SQL Equivalent: DELETE FROM User WHERE id = ?
   */
  deleteUser: async (id: number) => {
    return await prisma.user.delete({
      where: { id },
    });
  },

  /**
   * Find users by name (case-insensitive search)
   * @param name - Name to search for
   * @returns Array of matching users
   * SQL Equivalent: SELECT * FROM User WHERE name LIKE ? 
   */
  findUsersByName: async (name: string) => {
    return await prisma.user.findMany({
      where: {
        name: {
          contains: name,
          mode: 'insensitive', // Case-insensitive search
        },
      },
    });
  },

  /**
   * Check if email exists in database
   * @param email - Email to check
   * @returns Boolean indicating existence
   * SQL Equivalent: SELECT EXISTS(SELECT 1 FROM User WHERE email = ?)
   */
  checkEmailExists: async (email: string) => {
    const count = await prisma.user.count({
      where: { email },
    });
    return count > 0;
  },
};