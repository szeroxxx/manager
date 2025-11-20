'use client';

import { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layout/DashboardLayout';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import StatusBadge from '@/components/ui/StatusBadge';
import { apiClient, apiEndpoints } from '@/lib/api';
import { Users2, Plus, Mail, Shield, User } from 'lucide-react';

interface TeamMember {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: string;
  isActive: boolean;
  departmentId?: string;
  department?: {
    id: string;
    name: string;
  };
  createdAt: string;
}

export default function TeamPage() {
  const [teamMembers, setTeamMembers] = useState<TeamMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTeamMembers();
  }, []);

  const fetchTeamMembers = async () => {
    try {
      setLoading(true);
      const response = await apiClient.get<{ success: boolean; data: { users: TeamMember[] } }>(
        apiEndpoints.users.list
      );
      setTeamMembers(response.data.users);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch team members');
    } finally {
      setLoading(false);
    }
  };

  const getInitials = (firstName: string, lastName: string) => {
    return `${firstName[0]}${lastName[0]}`.toUpperCase();
  };

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'ADMIN':
        return 'gradient-warm';
      case 'MEMBER':
        return 'gradient-primary';
      case 'CLIENT':
        return 'gradient-accent';
      default:
        return 'bg-gray-600';
    }
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">Team</h1>
            <p className="text-gray-400 mt-1">Manage your team members</p>
          </div>
          <button className="btn-primary flex items-center gap-2">
            <Plus className="w-5 h-5" />
            Add Member
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
            <button onClick={fetchTeamMembers} className="btn-secondary mt-4">
              Try Again
            </button>
          </div>
        ) : teamMembers.length === 0 ? (
          <div className="glass-card p-12 text-center">
            <Users2 className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2">No team members yet</h3>
            <p className="text-gray-400 mb-6">Add your first team member to get started</p>
            <button className="btn-primary">
              <Plus className="w-5 h-5 inline mr-2" />
              Add Your First Team Member
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {teamMembers.map((member) => (
              <div key={member.id} className="glass-card p-6 hover-lift cursor-pointer">
                <div className="flex items-start gap-4 mb-4">
                  <div className={`w-16 h-16 rounded-full ${getRoleColor(member.role)} flex items-center justify-center text-white font-bold text-lg`}>
                    {getInitials(member.firstName, member.lastName)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-semibold text-white truncate">
                      {member.firstName} {member.lastName}
                    </h3>
                    <div className="flex items-center gap-2 mt-1">
                      <StatusBadge status={member.role} type="user" />
                      {!member.isActive && (
                        <span className="badge badge-error">Inactive</span>
                      )}
                    </div>
                  </div>
                </div>
                
                <div className="space-y-2 mb-4">
                  <div className="flex items-center gap-2 text-sm text-gray-300">
                    <Mail className="w-4 h-4 text-gray-500" />
                    <span className="truncate">{member.email}</span>
                  </div>
                  
                  {member.department && (
                    <div className="flex items-center gap-2 text-sm text-gray-300">
                      <Shield className="w-4 h-4 text-gray-500" />
                      <span>{member.department.name}</span>
                    </div>
                  )}
                </div>
                
                <div className="pt-4 border-t border-white/10">
                  <div className="flex items-center justify-between">
                    <p className="text-xs text-gray-500">
                      Joined {new Date(member.createdAt).toLocaleDateString()}
                    </p>
                    {member.isActive && (
                      <div className="flex items-center gap-1">
                        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                        <span className="text-xs text-green-500">Active</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
