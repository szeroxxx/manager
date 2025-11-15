"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const client_1 = require("@prisma/client");
const rateLimiter_1 = require("../middleware/rateLimiter");
const router = express_1.default.Router();
const prisma = new client_1.PrismaClient();
router.post('/register', async (req, res, next) => {
    try {
        const { email, password, firstName, lastName, role = 'MEMBER' } = req.body;
        const existingUser = await prisma.user.findUnique({
            where: { email },
        });
        if (existingUser) {
            return res.status(409).json({
                success: false,
                error: 'User already exists with this email',
            });
        }
        const saltRounds = parseInt(process.env.BCRYPT_ROUNDS || '12');
        const passwordHash = await bcryptjs_1.default.hash(password, saltRounds);
        const user = await prisma.user.create({
            data: {
                email,
                passwordHash,
                firstName,
                lastName,
                role,
            },
            select: {
                id: true,
                email: true,
                firstName: true,
                lastName: true,
                role: true,
                isActive: true,
                createdAt: true,
            },
        });
        res.status(201).json({
            success: true,
            message: 'User created successfully',
            user,
        });
    }
    catch (error) {
        next(error);
    }
});
router.post('/login', rateLimiter_1.authRateLimiter, async (req, res, next) => {
    try {
        const { email, password } = req.body;
        const user = await prisma.user.findUnique({
            where: { email },
        });
        if (!user) {
            return res.status(401).json({
                success: false,
                error: 'Invalid credentials',
            });
        }
        if (!user.isActive) {
            return res.status(403).json({
                success: false,
                error: 'User account is inactive',
            });
        }
        const isPasswordValid = await bcryptjs_1.default.compare(password, user.passwordHash);
        if (!isPasswordValid) {
            return res.status(401).json({
                success: false,
                error: 'Invalid credentials',
            });
        }
        const token = jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '15m' });
        const refreshToken = jsonwebtoken_1.default.sign({ id: user.id }, process.env.JWT_REFRESH_SECRET, { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' });
        res.json({
            success: true,
            token,
            refreshToken,
            user: {
                id: user.id,
                email: user.email,
                firstName: user.firstName,
                lastName: user.lastName,
                role: user.role,
                isActive: user.isActive,
                createdAt: user.createdAt,
            },
        });
    }
    catch (error) {
        next(error);
    }
});
router.post('/refresh', async (req, res, next) => {
    try {
        const { refreshToken } = req.body;
        if (!refreshToken) {
            return res.status(401).json({
                success: false,
                error: 'Refresh token is required',
            });
        }
        const decoded = jsonwebtoken_1.default.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
        const user = await prisma.user.findUnique({
            where: { id: decoded.id },
            select: { id: true, email: true, role: true, isActive: true },
        });
        if (!user || !user.isActive) {
            return res.status(401).json({
                success: false,
                error: 'Invalid refresh token',
            });
        }
        const newToken = jsonwebtoken_1.default.sign({ id: user.id, email: user.email, role: user.role }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES_IN || '15m' });
        res.json({
            success: true,
            token: newToken,
        });
    }
    catch (error) {
        res.status(401).json({
            success: false,
            error: 'Invalid refresh token',
        });
    }
});
exports.default = router;
//# sourceMappingURL=auth.js.map