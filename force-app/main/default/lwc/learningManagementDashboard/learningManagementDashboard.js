import { LightningElement } from 'lwc';

export default class LearningManagementDashboard extends LightningElement {
  completedCount = 9;
  notStartedCount = 7;
  inProgressCount = 14;

  enrollments = [
    {
      id: '1',
      studentName: 'William Garcia',
      email: 'william.garcia@futureventures.com',
      courseName: 'Sustainable Business Practices',
      courseId: 'COURSE-0010',
      progress: 10,
      progressStyle: 'width: 10%',
      createdDate: '02/25/2024',
      enrollmentId: 'ENR-0017'
    },
    {
      id: '2',
      studentName: 'Sarah Johnson',
      email: 'sarah.johnson@acmecorp.com',
      courseName: 'Digital Transformation Strategy',
      courseId: 'COURSE-0008',
      progress: 45,
      progressStyle: 'width: 45%',
      createdDate: '02/20/2024',
      enrollmentId: 'ENR-0016'
    },
    {
      id: '3',
      studentName: 'Michael Chen',
      email: 'michael.chen@techsolutions.io',
      courseName: 'Leadership Excellence Program',
      courseId: 'COURSE-0005',
      progress: 75,
      progressStyle: 'width: 75%',
      createdDate: '02/18/2024',
      enrollmentId: 'ENR-0015'
    },
    {
      id: '4',
      studentName: 'Emma Rodriguez',
      email: 'emma.rodriguez@globalsolutions.com',
      courseName: 'Financial Analysis Fundamentals',
      courseId: 'COURSE-0003',
      progress: 100,
      progressStyle: 'width: 100%',
      createdDate: '02/15/2024',
      enrollmentId: 'ENR-0014'
    },
    {
      id: '5',
      studentName: 'James Park',
      email: 'james.park@cloudbase.io',
      courseName: 'Innovation & Creativity Workshop',
      courseId: 'COURSE-0012',
      progress: 30,
      progressStyle: 'width: 30%',
      createdDate: '02/10/2024',
      enrollmentId: 'ENR-0013'
    }
  ];

  handleSearch(event) {
    const searchTerm = event.target.value.toLowerCase();
    const rows = this.template.querySelectorAll('tbody tr');

    rows.forEach(row => {
      const text = row.textContent.toLowerCase();
      row.style.display = text.includes(searchTerm) ? '' : 'none';
    });
  }
}