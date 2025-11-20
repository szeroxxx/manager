'use client';

import { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layout/DashboardLayout';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import StatusBadge from '@/components/ui/StatusBadge';
import { apiClient, apiEndpoints } from '@/lib/api';
import { CheckSquare, Plus, User, FolderKanban } from 'lucide-react';

interface Task {
  id: string;
  title: string;
  description?: string;
  status: string;
  priority: string;
  dueDate?: string;
  project: {
    id: string;
    name: string;
    client: {
      companyName: string;
    };
  };
  assignee?: {
    firstName: string;
    lastName: string;
  };
  createdAt: string;
}

const statusColumns = [
  { id: 'TODO', title: 'To Do', color: 'from-blue-500 to-blue-600' },
  { id: 'IN_PROGRESS', title: 'In Progress', color: 'from-yellow-500 to-orange-500' },
  { id: 'REVIEW', title: 'Review', color: 'from-purple-500 to-purple-600' },
  { id: 'DONE', title: 'Done', color: 'from-green-500 to-green-600' },
];

export default function TasksPage() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await apiClient.get<{ success: boolean; data: Task[] }>(
        apiEndpoints.tasks.list
      );
      setTasks(response.data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch tasks');
    } finally {
      setLoading(false);
    }
  };

  const getTasksByStatus = (status: string) => {
    return tasks.filter((task) => task.status === status);
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">Tasks</h1>
            <p className="text-gray-400 mt-1">Organize and track your tasks</p>
          </div>
          <button className="btn-primary flex items-center gap-2">
            <Plus className="w-5 h-5" />
            New Task
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
            <button onClick={fetchTasks} className="btn-secondary mt-4">
              Try Again
            </button>
          </div>
        ) : tasks.length === 0 ? (
          <div className="glass-card p-12 text-center">
            <CheckSquare className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2">No tasks yet</h3>
            <p className="text-gray-400 mb-6">Create your first task to get started</p>
            <button className="btn-primary">
              <Plus className="w-5 h-5 inline mr-2" />
              Create Your First Task
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {statusColumns.map((column) => {
              const columnTasks = getTasksByStatus(column.id);
              
              return (
                <div key={column.id} className="flex flex-col">
                  {/* Column Header */}
                  <div className={`glass-card p-4 mb-4 bg-gradient-to-r ${column.color}`}>
                    <h3 className="font-semibold text-white flex items-center justify-between">
                      {column.title}
                      <span className="text-sm bg-white/20 px-2 py-1 rounded-full">
                        {columnTasks.length}
                      </span>
                    </h3>
                  </div>
                  
                  {/* Tasks */}
                  <div className="space-y-3 flex-1">
                    {columnTasks.map((task) => (
                      <div key={task.id} className="glass-card p-4 hover-lift cursor-pointer">
                        <h4 className="font-semibold text-white mb-2">{task.title}</h4>
                        
                        {task.description && (
                          <p className="text-sm text-gray-400 mb-3 line-clamp-2">
                            {task.description}
                          </p>
                        )}
                        
                        <div className="space-y-2 mb-3">
                          <div className="flex items-center gap-2 text-xs text-gray-400">
                            <FolderKanban className="w-3 h-3" />
                            <span className="truncate">{task.project.name}</span>
                          </div>
                          
                          {task.assignee && (
                            <div className="flex items-center gap-2 text-xs text-gray-400">
                              <User className="w-3 h-3" />
                              <span>
                                {task.assignee.firstName} {task.assignee.lastName}
                              </span>
                            </div>
                          )}
                        </div>
                        
                        {task.dueDate && (
                          <div className="text-xs text-gray-500">
                            Due: {new Date(task.dueDate).toLocaleDateString()}
                          </div>
                        )}
                      </div>
                    ))}
                    
                    {columnTasks.length === 0 && (
                      <div className="glass-card p-4 text-center text-gray-500 text-sm">
                        No tasks
                      </div>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
