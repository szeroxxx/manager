# Company Management System

A comprehensive web-based company management system built with modern technologies, designed to streamline client management, project tracking, financial operations, and team collaboration.

## 🚀 Features

### Core Functionality
- **Client Management**: Complete client lifecycle management with contact tracking and status monitoring
- **Project Tracking**: Comprehensive project management with status indicators and progress tracking
- **Task Management**: Advanced task assignment and progress tracking system
- **Financial Management**: Invoice generation, payment tracking, and financial reporting
- **Team Management**: Employee directory with role-based permissions and department organization
- **Sales Pipeline**: Visual pipeline for client onboarding and sales tracking

### User Roles & Authentication
- **Three-tier Role System**: Admin, Member, and Client roles with granular permissions
- **JWT-based Authentication**: Secure token-based authentication with refresh tokens
- **Role-based UI**: Dynamic interface components based on user permissions

### Technical Features
- **Modern UI/UX**: Responsive, professional design optimized for 25-30 year old users
- **Real-time Updates**: Live data synchronization across the platform
- **Data Visualization**: Interactive charts and dashboards for business insights
- **Accessibility**: WCAG 2.1 AA compliant interface
- **Performance**: Optimized for fast loading and smooth user experience

## 🛠️ Technology Stack

### Frontend
- **Framework**: Next.js 14 with TypeScript
- **Styling**: Tailwind CSS with custom design system
- **State Management**: Zustand for global state
- **UI Components**: Custom components with Radix UI primitives
- **Data Visualization**: Recharts for interactive charts
- **Forms**: React Hook Form with Zod validation

### Backend
- **Runtime**: Node.js 18+ with Express.js
- **Language**: TypeScript
- **Database**: PostgreSQL 14+
- **ORM**: Prisma for database operations
- **Authentication**: JWT with refresh tokens
- **Validation**: Joi for request validation
- **API Documentation**: Swagger/OpenAPI

### Infrastructure
- **Containerization**: Docker and Docker Compose
- **Reverse Proxy**: Nginx with SSL termination
- **CI/CD**: GitHub Actions ready
- **Monitoring**: Health checks and logging

## 📦 Installation

### Prerequisites
- Node.js 18+ 
- PostgreSQL 14+
- Docker and Docker Compose (for containerized deployment)

### Local Development Setup

1. **Clone the repository**
```bash
git clone <repository-url>
cd company-management-system
```

2. **Backend Setup**
```bash
cd backend
npm install
cp .env.example .env
# Configure your .env file with database credentials
npm run prisma:migrate
npm run dev
```

3. **Frontend Setup**
```bash
cd frontend
npm install
cp .env.local.example .env.local
# Configure your environment variables
npm run dev
```

### Docker Deployment

For production deployment using Docker:

```bash
# Build and start all services
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
# API Documentation: http://localhost:5000/api-docs
```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```bash
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/company_management"

# JWT
JWT_SECRET="your-super-secret-jwt-key"
JWT_REFRESH_SECRET="your-super-secret-refresh-key"

# Server
PORT=5000
NODE_ENV=development
```

#### Frontend (.env.local)
```bash
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:5000
NEXT_PUBLIC_API_VERSION=/api
```

## 🚀 Usage

### Getting Started

1. **Access the application** at `http://localhost:3000`
2. **Create an admin account** through the registration process
3. **Log in** with your credentials
4. **Start managing** your company data

### Key Workflows

#### Client Management
- Add new clients with detailed contact information
- Track client status (prospect, active, inactive, churned)
- Manage client projects and communication history

#### Project Management
- Create projects with timelines and budgets
- Assign team members and track progress
- Monitor project status with visual indicators

#### Task Management
- Create and assign tasks to team members
- Track task progress and completion status
- Set priorities and due dates

#### Financial Management
- Generate invoices for clients and projects
- Track payment status (paid, pending, overdue)
- Monitor financial performance with reports

## 📊 API Documentation

The backend API is fully documented with Swagger/OpenAPI. Access the interactive documentation at:

```
http://localhost:5000/api-docs
```

### Key API Endpoints

- **Authentication**: `/api/auth/*`
- **Users**: `/api/users/*`
- **Clients**: `/api/clients/*`
- **Projects**: `/api/projects/*`
- **Tasks**: `/api/tasks/*`
- **Invoices**: `/api/invoices/*`
- **Departments**: `/api/departments/*`

## 🧪 Testing

### Backend Testing
```bash
cd backend
npm run test
npm run test:coverage
```

### Frontend Testing
```bash
cd frontend
npm run test
npm run test:e2e
```

## 🏗️ Architecture

### High-Level Architecture
```
Frontend (Next.js) → API Gateway (Nginx) → Backend (Express.js) → Database (PostgreSQL)
```

### Database Schema
The system uses a relational database with the following main entities:
- Users (with role-based permissions)
- Clients (with contact information)
- Projects (with status tracking)
- Tasks (with assignment and progress)
- Invoices (with payment tracking)
- Departments (for team organization)

## 🔒 Security

### Implemented Security Measures
- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: Bcrypt with configurable salt rounds
- **Input Validation**: Comprehensive request validation
- **Rate Limiting**: Protection against brute force attacks
- **CORS Configuration**: Proper cross-origin resource sharing
- **Helmet.js**: Security headers
- **SQL Injection Prevention**: Parameterized queries
- **XSS Protection**: Output encoding and sanitization

### OWASP Top 10 Compliance
The system addresses all OWASP Top 10 security risks:
1. Injection attacks
2. Broken authentication
3. Sensitive data exposure
4. XML external entities
5. Broken access control
6. Security misconfiguration
7. Cross-site scripting
8. Insecure deserialization
9. Using components with known vulnerabilities
10. Insufficient logging

## 📈 Performance

### Optimization Features
- **Code Splitting**: Automatic with Next.js
- **Image Optimization**: Next.js Image component
- **Database Indexing**: Optimized queries
- **Connection Pooling**: Efficient database connections
- **Response Compression**: Gzip compression
- **Caching Strategies**: Redis-ready architecture

### Performance Metrics
- **Lighthouse Score**: >90
- **First Contentful Paint**: <1.5s
- **Time to Interactive**: <3.5s
- **API Response Time**: <200ms (95th percentile)

## 🛠️ Development

### Code Structure
```
backend/
├── src/
│   ├── controllers/     # Request handlers
│   ├── middleware/      # Express middleware
│   ├── routes/         # API routes
│   ├── services/       # Business logic
│   ├── utils/          # Utility functions
│   └── types/          # TypeScript types
├── prisma/             # Database schema
└── tests/              # Test files

frontend/
├── src/
│   ├── app/            # Next.js app directory
│   ├── components/     # React components
│   ├── hooks/          # Custom React hooks
│   ├── lib/            # Utility libraries
│   ├── stores/         # Zustand stores
│   └── types/          # TypeScript types
└── public/             # Static assets
```

### Development Commands

#### Backend
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run test         # Run tests
npm run lint         # Lint code
```

#### Frontend
```bash
npm run dev          # Start development server
npm run build        # Build for production
npm run start        # Start production server
npm run test         # Run tests
npm run lint         # Lint code
```

## 🚢 Deployment

### Production Deployment
See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed deployment instructions.

### Environment-Specific Configurations
- **Development**: Hot reloading, detailed error messages
- **Staging**: Production-like with debug capabilities
- **Production**: Optimized for performance and security

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Run the test suite
6. Submit a pull request

### Code Standards
- Follow TypeScript best practices
- Write comprehensive tests
- Document API endpoints
- Follow security guidelines
- Maintain backward compatibility

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Check the [documentation](docs/)
- Review the [troubleshooting guide](docs/TROUBLESHOOTING.md)
- Open an issue on GitHub
- Contact the development team

## 🔄 Updates

The system is designed to be easily updatable:
- **Database Migrations**: Automated via Prisma
- **Zero-downtime Deployments**: Rolling updates with Docker
- **Backward Compatibility**: API versioning support
- **Hot Reloading**: Development environment

---

**Built with ❤️ for modern business management**