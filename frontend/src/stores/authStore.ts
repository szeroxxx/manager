import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { AuthUser, LoginCredentials, AuthResponse } from '@/types';

interface AuthState {
  user: AuthUser | null;
  token: string | null;
  refreshToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  
  // Actions
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  setAuth: (authData: AuthResponse) => void;
  clearError: () => void;
  checkAuth: () => boolean;
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000';

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      refreshToken: null,
      isAuthenticated: false,
      isLoading: false,
      error: null,

      login: async (credentials: LoginCredentials) => {
        set({ isLoading: true, error: null });
        
        try {
          const response = await fetch(`${API_URL}/api/auth/login`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(credentials),
          });

          const data = await response.json();

          if (!response.ok) {
            throw new Error(data.error || 'Login failed');
          }

          set({
            user: data.user,
            token: data.token,
            refreshToken: data.refreshToken,
            isAuthenticated: true,
            isLoading: false,
            error: null,
          });
        } catch (error) {
          set({
            isLoading: false,
            error: error instanceof Error ? error.message : 'Login failed',
          });
          throw error;
        }
      },

      logout: () => {
        set({
          user: null,
          token: null,
          refreshToken: null,
          isAuthenticated: false,
          isLoading: false,
          error: null,
        });
      },

      setAuth: (authData: AuthResponse) => {
        set({
          user: authData.user,
          token: authData.token,
          refreshToken: authData.refreshToken,
          isAuthenticated: true,
          isLoading: false,
          error: null,
        });
      },

      clearError: () => {
        set({ error: null });
      },

      checkAuth: () => {
        const { token, user } = get();
        const isValid = !!(token && user);
        
        if (!isValid && token) {
          // Token exists but user doesn't, clear the invalid state
          get().logout();
        }
        
        return isValid;
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        refreshToken: state.refreshToken,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
);