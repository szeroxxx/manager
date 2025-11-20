'use client';

import { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layout/DashboardLayout';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import StatusBadge from '@/components/ui/StatusBadge';
import { apiClient, apiEndpoints } from '@/lib/api';
import { FolderKanban, Plus, Calendar, User } from 'lucide-react';

interface Project {
  id: string;
  name: string;
  description?: string;
  status: string;
  startDate: string;
  endDate?: string;
  client: {
    id: string;
    companyName: string;
  };
  creator: {
    firstName: string;
    lastName: string;
  };
  createdAt: string;
}

export default function ProjectsPage() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchProjects();
  }, []);

  const fetchProjects = async () => {
    try {
      setLoading(true);
      const response = await apiClient.get<{ success: boolean; data: Project[] }>(
        apiEndpoints.projects.list
      );
      setProjects(response.data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch projects');
    } finally {
      setLoading(false);
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">Projects</h1>
            <p className="text-gray-400 mt-1">Track and manage your projects</p>
          </div>
          <button className="btn-primary flex items-center gap-2">
            <Plus className="w-5 h-5" />
            New Project
          </button>
        </div>

        {/* Content */}
        {loading ? (
          <div className="flex items-center justify-center h-64">
            <LoadingSpinner size="lg" />
          </div>
        ) : error ? (
          <div className="glass-card p-8 text-center">
            <p className="text-red-400">{error}</p>
            <button onClick={fetchProjects} className="btn-secondary mt-4">
              Try Again
            </button>
          </div>
        ) : projects.length === 0 ? (
          <div className="glass-card p-12 text-center">
            <FolderKanban className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2">No projects yet</h3>
            <p className="text-gray-400 mb-6">Create your first project to get started</p>
            <button className="btn-primary">
              <Plus className="w-5 h-5 inline mr-2" />
              Create Your First Project
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {projects.map((project) => (
              <div key={project.id} className="glass-card p-6 hover-lift cursor-pointer">
                <div className="flex items-start justify-between mb-4">
                  <div className="w-12 h-12 rounded-lg gradient-primary flex items-center justify-center">
                    <FolderKanban className="w-6 h-6 text-white" />
                  </div>
                  <StatusBadge status={project.status} type="project" />
                </div>
                
                <h3 className="text-lg font-semibold text-white mb-2">
                  {project.name}
                </h3>
                
                {project.description && (
                  <p className="text-sm text-gray-400 mb-4 line-clamp-2">
                    {project.description}
                  </p>
                )}
                
                <div className="space-y-2 mb-4">
                  <div className="flex items-center gap-2 text-sm text-gray-300">
                    <User className="w-4 h-4 text-gray-500" />
                    <span className="truncate">{project.client.companyName}</span>
                  </div>
                  <div className="flex items-center gap-2 text-sm text-gray-300">
                    <Calendar className="w-4 h-4 text-gray-500" />
                    <span>
                      {new Date(project.startDate).toLocaleDateString()}
                      {project.endDate && ` - ${new Date(project.endDate).toLocaleDateString()}`}
                    </span>
                  </div>
                </div>
                
                <div className="pt-4 border-t border-white/10">
                  <p className="text-xs text-gray-500">
                    Created by {project.creator.firstName} {project.creator.lastName}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
