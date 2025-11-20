import DashboardLayout from '@/components/layout/DashboardLayout';
import { Users, FolderKanban, CheckSquare, DollarSign, TrendingUp, Clock } from 'lucide-react';

export default function DashboardPage() {
  const stats = [
    {
      title: 'Total Clients',
      value: '24',
      icon: Users,
      color: 'from-blue-500 to-blue-600',
      bgColor: 'bg-blue-500/10',
      iconColor: 'text-blue-500',
    },
    {
      title: 'Active Projects',
      value: '12',
      icon: FolderKanban,
      color: 'from-green-500 to-green-600',
      bgColor: 'bg-green-500/10',
      iconColor: 'text-green-500',
    },
    {
      title: 'Pending Tasks',
      value: '8',
      icon: CheckSquare,
      color: 'from-yellow-500 to-yellow-600',
      bgColor: 'bg-yellow-500/10',
      iconColor: 'text-yellow-500',
    },
    {
      title: 'Revenue',
      value: '$45,231',
      icon: DollarSign,
      color: 'from-purple-500 to-purple-600',
      bgColor: 'bg-purple-500/10',
      iconColor: 'text-purple-500',
    },
  ];

  const recentActivity = [
    {
      title: 'New project created: Website Redesign',
      time: '2 hours ago',
      icon: FolderKanban,
      color: 'text-green-500',
    },
    {
      title: 'Client onboarding completed: Tech Corp',
      time: '4 hours ago',
      icon: Users,
      color: 'text-blue-500',
    },
    {
      title: 'Task assigned: Database Migration',
      time: '6 hours ago',
      icon: CheckSquare,
      color: 'text-yellow-500',
    },
  ];

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, index) => {
            const Icon = stat.icon;
            return (
              <div
                key={index}
                className="glass-card p-6 hover-lift cursor-pointer"
              >
                <div className="flex items-center justify-between mb-4">
                  <div className={`w-12 h-12 rounded-lg ${stat.bgColor} flex items-center justify-center`}>
                    <Icon className={`w-6 h-6 ${stat.iconColor}`} />
                  </div>
                  <TrendingUp className="w-5 h-5 text-green-500" />
                </div>
                <p className="text-sm font-medium text-gray-400 mb-1">{stat.title}</p>
                <p className="text-3xl font-bold text-white">{stat.value}</p>
              </div>
            );
          })}
        </div>

        {/* Recent Activity */}
        <div className="glass-card overflow-hidden">
          <div className="px-6 py-4 border-b border-white/10">
            <h3 className="text-lg font-semibold text-white">Recent Activity</h3>
          </div>
          <div className="p-6">
            <div className="space-y-4">
              {recentActivity.map((activity, index) => {
                const Icon = activity.icon;
                return (
                  <div key={index} className="flex items-start gap-4 group cursor-pointer">
                    <div className={`w-10 h-10 rounded-lg bg-white/5 flex items-center justify-center group-hover:bg-white/10 transition-colors`}>
                      <Icon className={`w-5 h-5 ${activity.color}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm text-white group-hover:text-gray-200 transition-colors">
                        {activity.title}
                      </p>
                      <div className="flex items-center gap-2 mt-1">
                        <Clock className="w-3 h-3 text-gray-500" />
                        <p className="text-xs text-gray-500">{activity.time}</p>
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </DashboardLayout>
  );
}