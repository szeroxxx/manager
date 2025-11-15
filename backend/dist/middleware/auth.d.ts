import { Response, NextFunction } from 'express';
import { AuthenticatedRequest } from './errorHandler';
export declare const authenticate: (req: AuthenticatedRequest, res: Response, next: NextFunction) => Promise<void | any>;
export declare const authorize: (roles: string[]) => (req: AuthenticatedRequest, res: Response, next: NextFunction) => void | any;
//# sourceMappingURL=auth.d.ts.map