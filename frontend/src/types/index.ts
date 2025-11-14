// User Types
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'ADMIN' | 'MEMBER' | 'CLIENT';
  isActive: boolean;
  departmentId?: string;
  createdAt: string;
  updatedAt: string;
}

export interface AuthUser extends Omit<User, 'createdAt' | 'updatedAt'> {
  department?: {
    id: string;
    name: string;
  };
}

// Client Types
export interface Client {
  id: string;
  companyName: string;
  contactPerson?: string;
  email?: string;
  phone?: string;
  address?: string;
  status: 'PROSPECT' | 'ACTIVE' | 'INACTIVE' | 'CHURNED';
  createdAt: string;
  updatedAt: string;
}

// Project Types
export interface Project {
  id: string;
  name: string;
  description?: string;
  clientId: string;
  client: Client;
  status: 'PLANNING' | 'IN_PROGRESS' | 'ON_HOLD' | 'COMPLETED' | 'CANCELLED';
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  startDate?: string;
  endDate?: string;
  budget?: number;
  createdBy: string;
  creator: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
  createdAt: string;
  updatedAt: string;
}

// Task Types
export interface Task {
  id: string;
  title: string;
  description?: string;
  projectId: string;
  project: {
    id: string;
    name: string;
    client: {
      id: string;
      companyName: string;
    };
  };
  assignedTo?: string;
  assignee?: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
  status: 'TODO' | 'IN_PROGRESS' | 'REVIEW' | 'COMPLETED';
  priority: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  dueDate?: string;
  progress: number;
  createdAt: string;
  updatedAt: string;
}

// Invoice Types
export interface Invoice {
  id: string;
  invoiceNumber: string;
  clientId: string;
  client: {
    id: string;
    companyName: string;
    contactPerson?: string;
  };
  projectId?: string;
  project?: {
    id: string;
    name: string;
  };
  amount: number;
  taxAmount: number;
  totalAmount: number;
  status: 'DRAFT' | 'SENT' | 'PAID' | 'OVERDUE' | 'CANCELLED';
  dueDate?: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

// Department Types
export interface Department {
  id: string;
  name: string;
  description?: string;
  managerId?: string;
  manager?: {
    id: string;
    firstName: string;
    lastName: string;
    email: string;
  };
  members: User[];
  createdAt: string;
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface PaginatedResponse<T> {
  items: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// Auth Types
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  success: boolean;
  token: string;
  refreshToken: string;
  user: AuthUser;
}

// Dashboard Types
export interface DashboardStats {
  totalClients: number;
  activeProjects: number;
  pendingTasks: number;
  overdueInvoices: number;
  totalRevenue: number;
  monthlyGrowth: number;
}

// Form Types
export interface CreateClientForm {
  companyName: string;
  contactPerson?: string;
  email?: string;
  phone?: string;
  address?: string;
  status?: Client['status'];
}

export interface CreateProjectForm {
  name: string;
  description?: string;
  clientId: string;
  status?: Project['status'];
  priority?: Project['priority'];
  startDate?: string;
  endDate?: string;
  budget?: number;
}

export interface CreateTaskForm {
  title: string;
  description?: string;
  projectId: string;
  assignedTo?: string;
  status?: Task['status'];
  priority?: Task['priority'];
  dueDate?: string;
}

export interface CreateInvoiceForm {
  invoiceNumber: string;
  clientId: string;
  projectId?: string;
  amount: number;
  taxAmount?: number;
  totalAmount: number;
  status?: Invoice['status'];
  dueDate?: string;
}