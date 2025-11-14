'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/stores/authStore';

interface DashboardLayoutProps {
  children: React.ReactNode;
}

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const router = useRouter();
  const { isAuthenticated, checkAuth } = useAuthStore();

  useEffect(() => {
    if (!checkAuth()) {
      router.push('/login');
    }
  }, [router, checkAuth]);

  if (!isAuthenticated) {
    return null; // Or a loading spinner
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="flex h-screen">
        {/* Sidebar */}
        <div className="w-64 bg-white shadow-lg">
          <div className="p-6">
            <h1 className="text-2xl font-bold text-gray-800">Company MS</h1>
          </div>
          <nav className="mt-6">
            <a
              href="/dashboard"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Dashboard</span>
            </a>
            <a
              href="/dashboard/clients"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Clients</span>
            </a>
            <a
              href="/dashboard/projects"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Projects</span>
            </a>
            <a
              href="/dashboard/tasks"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Tasks</span>
            </a>
            <a
              href="/dashboard/invoices"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Invoices</span>
            </a>
            <a
              href="/dashboard/team"
              className="flex items-center px-6 py-3 text-gray-700 hover:bg-gray-100"
            >
              <span className="mx-3">Team</span>
            </a>
          </nav>
        </div>

        {/* Main Content */}
        <div className="flex-1 flex flex-col">
          {/* Header */}
          <header className="bg-white shadow-sm">
            <div className="flex items-center justify-between px-6 py-4">
              <h2 className="text-xl font-semibold text-gray-800">Dashboard</h2>
              <div className="flex items-center space-x-4">
                <span className="text-sm text-gray-600">Welcome back!</span>
                <button
                  onClick={() => {
                    useAuthStore.getState().logout();
                    router.push('/login');
                  }}
                  className="text-sm text-gray-600 hover:text-gray-800"
                >
                  Logout
                </button>
              </div>
            </div>
          </header>

          {/* Page Content */}
          <main className="flex-1 overflow-y-auto bg-gray-50 p-6">
            {children}
          </main>
        </div>
      </div>
    </div>
  );
}