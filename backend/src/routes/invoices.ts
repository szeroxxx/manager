import express from 'express';
import { PrismaClient } from '@prisma/client';
import { authenticate, authorize } from '../middleware/auth';

const router = express.Router();
const prisma = new PrismaClient();

/**
 * @swagger
 * /api/invoices:
 *   get:
 *     summary: Get all invoices
 *     tags: [Invoices]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Invoices retrieved successfully
 *       401:
 *         description: Unauthorized
 */
router.get('/', authenticate, async (req, res, next) => {
  try {
    const invoices = await prisma.invoice.findMany({
      include: {
        client: {
          select: {
            id: true,
            companyName: true,
            contactPerson: true,
          },
        },
        project: {
          select: {
            id: true,
            name: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({
      success: true,
      data: invoices,
    });
  } catch (error) {
    next(error);
  }
});

export default router;