"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const client_1 = require("@prisma/client");
const prisma = new client_1.PrismaClient();
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);
    let error = { ...err };
    error.message = err.message;
    if (err.code === 'P2002') {
        const message = 'Duplicate field value entered';
        error = { message, statusCode: 400 };
    }
    if (err.code === 'P2014') {
        const message = 'Invalid ID provided';
        error = { message, statusCode: 400 };
    }
    if (err.code === 'P2003') {
        const message = 'Invalid input data';
        error = { message, statusCode: 400 };
    }
    if (err.name === 'JsonWebTokenError') {
        const message = 'Invalid token';
        error = { message, statusCode: 401 };
    }
    if (err.name === 'TokenExpiredError') {
        const message = 'Token expired';
        error = { message, statusCode: 401 };
    }
    res.status(error.statusCode || 500).json({
        success: false,
        error: error.message || 'Server Error',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    });
};
exports.errorHandler = errorHandler;
//# sourceMappingURL=errorHandler.js.map