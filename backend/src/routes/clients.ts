import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * @swagger
 * /api/clients:
 *   get:
 *     summary: Get all clients
 *     tags: [Clients]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Clients retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get('/', authenticate, async (req, res, next) => {
  try {
    const clients = await prisma.client.findMany({
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      data: clients,
    });
  } catch (error) {
    next(error);
  }
});

export default router;