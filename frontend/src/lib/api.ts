import { useAuthStore } from '@/stores/authStore';

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000';

class ApiClient {
  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const { token, logout } = useAuthStore.getState();
    
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...options.headers as Record<string, string>,
    };

    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }

    const response = await fetch(`${API_URL}${endpoint}`, {
      ...options,
      headers,
    });

    if (response.status === 401) {
      // Token expired or invalid, logout the user
      logout();
      throw new Error('Authentication failed');
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'API request failed');
    }

    return data;
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async put<T>(endpoint: string, data?: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });
  }

  async delete<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE' });
  }

  async upload<T>(endpoint: string, formData: FormData): Promise<T> {
    const { token, logout } = useAuthStore.getState();
    
    const headers: HeadersInit = {};
    
    if (token) {
      headers.Authorization = `Bearer ${token}`;
    }

    const response = await fetch(`${API_URL}${endpoint}`, {
      method: 'POST',
      headers,
      body: formData,
    });

    if (response.status === 401) {
      logout();
      throw new Error('Authentication failed');
    }

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || 'Upload failed');
    }

    return data;
  }
}

export const apiClient = new ApiClient();

// API endpoints
export const apiEndpoints = {
  auth: {
    login: '/api/auth/login',
    register: '/api/auth/register',
    refresh: '/api/auth/refresh',
    profile: '/api/auth/profile',
  },
  users: {
    list: '/api/users',
    profile: '/api/users/profile',
    detail: (id: string) => `/api/users/${id}`,
  },
  clients: {
    list: '/api/clients',
    detail: (id: string) => `/api/clients/${id}`,
    projects: (id: string) => `/api/clients/${id}/projects`,
  },
  projects: {
    list: '/api/projects',
    detail: (id: string) => `/api/projects/${id}`,
    tasks: (id: string) => `/api/projects/${id}/tasks`,
  },
  tasks: {
    list: '/api/tasks',
    detail: (id: string) => `/api/tasks/${id}`,
    progress: (id: string) => `/api/tasks/${id}/progress`,
  },
  invoices: {
    list: '/api/invoices',
    detail: (id: string) => `/api/invoices/${id}`,
    status: (id: string) => `/api/invoices/${id}/status`,
  },
  departments: {
    list: '/api/departments',
    detail: (id: string) => `/api/departments/${id}`,
  },
  financial: {
    summary: '/api/financial/summary',
  },
};