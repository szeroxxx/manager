'use client';

import { useEffect, useState } from 'react';
import DashboardLayout from '@/components/layout/DashboardLayout';
import LoadingSpinner from '@/components/ui/LoadingSpinner';
import StatusBadge from '@/components/ui/StatusBadge';
import { apiClient, apiEndpoints } from '@/lib/api';
import { FileText, Plus, Building2, FolderKanban, DollarSign } from 'lucide-react';

interface Invoice {
  id: string;
  invoiceNumber: string;
  amount: number;
  status: string;
  issueDate: string;
  dueDate: string;
  client: {
    id: string;
    companyName: string;
    contactPerson: string;
  };
  project?: {
    id: string;
    name: string;
  };
  createdAt: string;
}

export default function InvoicesPage() {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchInvoices();
  }, []);

  const fetchInvoices = async () => {
    try {
      setLoading(true);
      const response = await apiClient.get<{ success: boolean; data: Invoice[] }>(
        apiEndpoints.invoices.list
      );
      setInvoices(response.data);
    } catch (err: any) {
      setError(err.message || 'Failed to fetch invoices');
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  return (
    <DashboardLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white">Invoices</h1>
            <p className="text-gray-400 mt-1">Manage your billing and payments</p>
          </div>
          <button className="btn-primary flex items-center gap-2">
            <Plus className="w-5 h-5" />
            New Invoice
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
            <button onClick={fetchInvoices} className="btn-secondary mt-4">
              Try Again
            </button>
          </div>
        ) : invoices.length === 0 ? (
          <div className="glass-card p-12 text-center">
            <FileText className="w-16 h-16 text-gray-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-white mb-2">No invoices yet</h3>
            <p className="text-gray-400 mb-6">Create your first invoice to get started</p>
            <button className="btn-primary">
              <Plus className="w-5 h-5 inline mr-2" />
              Create Your First Invoice
            </button>
          </div>
        ) : (
          <div className="glass-card overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-white/10">
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Invoice #</th>
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Client</th>
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Project</th>
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Amount</th>
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Due Date</th>
                    <th className="text-left p-4 text-sm font-semibold text-gray-400">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {invoices.map((invoice) => (
                    <tr
                      key={invoice.id}
                      className="border-b border-white/5 hover:bg-white/5 transition-colors cursor-pointer"
                    >
                      <td className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-lg gradient-warm flex items-center justify-center">
                            <FileText className="w-5 h-5 text-white" />
                          </div>
                          <span className="font-medium text-white">{invoice.invoiceNumber}</span>
                        </div>
                      </td>
                      <td className="p-4">
                        <div>
                          <p className="text-white font-medium">{invoice.client.companyName}</p>
                          <p className="text-sm text-gray-400">{invoice.client.contactPerson}</p>
                        </div>
                      </td>
                      <td className="p-4">
                        {invoice.project ? (
                          <div className="flex items-center gap-2 text-gray-300">
                            <FolderKanban className="w-4 h-4 text-gray-500" />
                            <span>{invoice.project.name}</span>
                          </div>
                        ) : (
                          <span className="text-gray-500">-</span>
                        )}
                      </td>
                      <td className="p-4">
                        <div className="flex items-center gap-2">
                          <DollarSign className="w-4 h-4 text-green-500" />
                          <span className="font-semibold text-white">
                            {formatCurrency(invoice.amount)}
                          </span>
                        </div>
                      </td>
                      <td className="p-4">
                        <span className="text-gray-300">
                          {new Date(invoice.dueDate).toLocaleDateString()}
                        </span>
                      </td>
                      <td className="p-4">
                        <StatusBadge status={invoice.status} type="invoice" />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </DashboardLayout>
  );
}
