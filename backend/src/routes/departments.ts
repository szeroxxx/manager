import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * @swagger
 * /api/departments:
 *   get:
 *     summary: Get all departments
 *     tags: [Departments]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Departments retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get('/', authenticate, async (req, res, next) => {
  try {
    const departments = await prisma.department.findMany({
      include: {
        manager: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
        members: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      data: departments,
    });
  } catch (error) {
    next(error);
  }
});

export default router;