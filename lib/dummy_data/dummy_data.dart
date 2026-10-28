// Sample 1: Full details (Management)
import 'package:hrms_ai_copilot/models/employee.dart';
import 'package:hrms_ai_copilot/models/leave_balance.dart';
import 'package:hrms_ai_copilot/models/leave_request.dart';

final employee1 = Employee(
  id: 1,
  employeeCode: 'EMP-1001',
  name: 'Sarah Jenkins',
  email: 'sarah.jenkins@company.com',
  phone: '+1 (555) 234-5678',
  address: '742 Evergreen Terrace, Springfield, OR 97477',
  role: 'Engineering Manager',
  department: 'Engineering',
  departmentId: 1,
  managerId: null, // Top-level manager
  profileImageUrl: 'https://i.pravatar.cc/150?img=47',
  isActive: true,
  createdAt: DateTime.parse('2022-01-15T09:00:00Z'),
  updatedAt: DateTime.parse('2024-03-10T14:30:00Z'),
);

// Sample 2: Senior Developer (Reports to Sarah)
final employee2 = Employee(
  id: 2,
  employeeCode: 'EMP-1002',
  name: 'Alex Rivera',
  email: 'alex.rivera@company.com',
  phone: '+1 (555) 876-5432',
  address: '101 Market St, Apt 4B, San Francisco, CA 94105',
  role: 'Senior Flutter Developer',
  department: 'Engineering',
  departmentId: 1,
  managerId: 2,
  profileImageUrl: 'https://i.pravatar.cc/150?img=12',
  isActive: true,
  createdAt: DateTime.parse('2022-06-01T10:15:00Z'),
  updatedAt: DateTime.parse('2024-01-20T11:45:00Z'),
);

// Sample 3: Product Designer
final employee3 = Employee(
  id: 3,
  employeeCode: 'EMP-1003',
  name: 'Emily Chen',
  email: 'emily.chen@company.com',
  phone: '+1 (555) 345-6789',
  address: '456 Oak Avenue, Seattle, WA 98101',
  role: 'UI/UX Designer',
  department: 'Product & Design',
  departmentId: 1,
  managerId: 2,
  profileImageUrl: 'https://i.pravatar.cc/150?img=32',
  isActive: true,
  createdAt: DateTime.parse('2023-02-10T08:30:00Z'),
  updatedAt: DateTime.parse('2024-02-15T16:00:00Z'),
);

// Sample 4: Inactive Employee (Former staff)
final employee4 = Employee(
  id: 4,
  employeeCode: 'EMP-1004',
  name: 'Michael Scott',
  email: 'michael.scott@company.com',
  phone: '+1 (555) 999-0000',
  address: '1725 Slough Avenue, Scranton, PA 18503',
  role: 'Regional Manager',
  department: 'Sales',
  departmentId: 4,
  managerId: null,
  profileImageUrl: 'https://i.pravatar.cc/150?img=68',
  isActive: false, // Inactive / Offboarded
  createdAt: DateTime.parse('2020-03-01T09:00:00Z'),
  updatedAt: DateTime.parse('2023-11-30T17:00:00Z'),
);

// Sample 5: Minimal configuration (Only required fields provided)
final employee5 = Employee(
  id: 5,
  employeeCode: 'EMP-1005',
  name: 'David Kim',
  email: 'david.kim@company.com',
  role: 'QA Engineer',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// List representation for mock services / repositories
final List<Employee> dummyEmployees = [
  employee1,
  employee2,
  employee3,
  employee4,
  employee5,
];

// ==========================================
// DUMMY LEAVE BALANCES LIST
// ==========================================
final List<LeaveBalance> dummyLeaveBalances = [
  // Sarah Jenkins (emp_001) - Standard allocation with low usage
  const LeaveBalance(
    id: 1,
    employeeId: 1,
    year: 2026,
    annualLeave: 20.0,
    medicalLeave: 10.0,
    casualLeave: 7.0,
    annualUsed: 4.0,
    medicalUsed: 1.0,
    casualUsed: 2.0,
    carryForward: 3.0,
  ),

  // Alex Rivera (emp_002) - High usage of annual leave
  const LeaveBalance(
    id: 2,
    employeeId: 2,
    year: 2026,
    annualLeave: 20.0,
    medicalLeave: 10.0,
    casualLeave: 7.0,
    annualUsed: 15.0,
    medicalUsed: 3.0,
    casualUsed: 5.0,
    carryForward: 5.0,
  ),

  // Emily Chen (emp_003) - Fresh allocation with carry-forward
  const LeaveBalance(
    id: 3,
    employeeId: 3,
    year: 2026,
    annualLeave: 20.0,
    medicalLeave: 10.0,
    casualLeave: 7.0,
    annualUsed: 2.0,
    medicalUsed: 0.0,
    casualUsed: 1.0,
    carryForward: 2.0,
  ),

  // Michael Scott (emp_004) - Inactive employee balance
  const LeaveBalance(
    id: 4,
    employeeId: 4,
    year: 2026,
    annualLeave: 0.0,
    medicalLeave: 0.0,
    casualLeave: 0.0,
    annualUsed: 0.0,
    medicalUsed: 0.0,
    casualUsed: 0.0,
    carryForward: 0.0,
  ),

  // David Kim (emp_005) - New hire allocation (Pro-rated)
  const LeaveBalance(
    id: 5,
    employeeId: 5,
    year: 2026,
    annualLeave: 10.0,
    medicalLeave: 5.0,
    casualLeave: 3.5,
    annualUsed: 0.0,
    medicalUsed: 0.0,
    casualUsed: 0.0,
    carryForward: 0.0,
  ),
];

// ==========================================
// DUMMY LEAVE REQUESTS LIST
// ==========================================
final List<LeaveRequest> dummyLeaveRequests = [
  // Request 1: Approved Annual Leave (Alex Rivera)
  LeaveRequest(
    id: 1,
    employeeId: 1,
    leaveType: 'Annual',
    startDate: DateTime.parse('2026-07-10T00:00:00Z'),
    endDate: DateTime.parse('2026-07-17T23:59:59Z'),
    reason: 'Family summer vacation in Hawaii.',
    status: 'Approved',
    approvedBy: 2, // Approved by Sarah Jenkins
    comment: 'Approved. Ensure test coverage is complete before leaving.',
    createdAt: DateTime.parse('2026-06-15T09:30:00Z'),
    updatedAt: DateTime.parse('2026-06-16T11:20:00Z'),
  ),

  // Request 2: Pending Medical Leave (Emily Chen)
  LeaveRequest(
    id: 2,
    employeeId: 2,
    leaveType: 'Medical',
    startDate: DateTime.parse('2026-09-29T00:00:00Z'),
    endDate: DateTime.parse('2026-09-30T23:59:59Z'),
    reason: 'Dental surgery and recovery.',
    status: 'Pending',
    approvedBy: null,
    comment: null,
    createdAt: DateTime.parse('2026-09-27T14:10:00Z'),
    updatedAt: DateTime.parse('2026-09-27T14:10:00Z'),
  ),

  // Request 3: Rejected Casual Leave (Alex Rivera)
  LeaveRequest(
    id: 3,
    employeeId: 3,
    leaveType: 'Casual',
    startDate: DateTime.parse('2026-08-05T00:00:00Z'),
    endDate: DateTime.parse('2026-08-05T23:59:59Z'),
    reason: 'Personal errand.',
    rejectionReason: 'Conflict with major release deployment day.',
    status: 'Rejected',
    approvedBy: 2,
    comment: 'Please reschedule for another day after release week.',
    createdAt: DateTime.parse('2026-08-01T16:45:00Z'),
    updatedAt: DateTime.parse('2026-08-02T08:15:00Z'),
  ),

  // Request 4: Approved Short Casual Leave (Sarah Jenkins)
  LeaveRequest(
    id: 4,
    employeeId: 4,
    leaveType: 'Casual',
    startDate: DateTime.parse('2026-05-12T00:00:00Z'),
    endDate: DateTime.parse('2026-05-12T23:59:59Z'),
    reason: 'Home maintenance work.',
    status: 'Approved',
    approvedBy: 2,
    comment: 'Auto-approved for manager level.',
    createdAt: DateTime.parse('2026-05-02T10:00:00Z'),
    updatedAt: DateTime.parse('2026-05-02T10:01:00Z'),
  ),

  // Request 5: Minimal details / Draft or Pending (David Kim)
  LeaveRequest(
    id: 5,
    employeeId: 5,
    leaveType: 'Annual',
    startDate: DateTime.parse('2026-10-15T00:00:00Z'),
    endDate: DateTime.parse('2026-10-20T23:59:59Z'),
    status: 'Pending',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
