interface StatusBadgeProps {
  status: string;
  type?: 'project' | 'task' | 'invoice' | 'user';
}

export default function StatusBadge({ status, type = 'project' }: StatusBadgeProps) {
  const getStatusStyle = () => {
    const upperStatus = status.toUpperCase();
    
    // Project statuses
    if (type === 'project') {
      switch (upperStatus) {
        case 'PLANNING':
          return 'badge-info';
        case 'IN_PROGRESS':
          return 'badge-warning';
        case 'COMPLETED':
          return 'badge-success';
        case 'ON_HOLD':
          return 'badge-error';
        default:
          return 'badge-info';
      }
    }
    
    // Task statuses
    if (type === 'task') {
      switch (upperStatus) {
        case 'TODO':
          return 'badge-info';
        case 'IN_PROGRESS':
          return 'badge-warning';
        case 'REVIEW':
          return 'badge-purple';
        case 'DONE':
          return 'badge-success';
        default:
          return 'badge-info';
      }
    }
    
    // Invoice statuses
    if (type === 'invoice') {
      switch (upperStatus) {
        case 'DRAFT':
          return 'badge-info';
        case 'SENT':
          return 'badge-warning';
        case 'PAID':
          return 'badge-success';
        case 'OVERDUE':
          return 'badge-error';
        default:
          return 'badge-info';
      }
    }
    
    // User statuses
    if (type === 'user') {
      switch (upperStatus) {
        case 'ADMIN':
          return 'badge-error';
        case 'MEMBER':
          return 'badge-info';
        case 'CLIENT':
          return 'badge-purple';
        default:
          return 'badge-info';
      }
    }
    
    return 'badge-info';
  };

  const formatStatus = (status: string) => {
    return status.replace(/_/g, ' ');
  };

  return (
    <span className={`badge ${getStatusStyle()}`}>
      {formatStatus(status)}
    </span>
  );
}
