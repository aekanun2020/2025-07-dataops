# Loan ETL Pipeline with CI/CD

โปรเจคนี้เป็น ETL (Extract, Transform, Load) pipeline สำหรับข้อมูล loan พร้อมระบบ CI/CD

## โครงสร้างโปรเจค

```
2025-07-25/
├── pre-production/         # Source code หลัก
│   ├── config/            # Configuration files
│   ├── utils/             # Utility functions
│   ├── etl/               # ETL functions
│   └── main.py            # Main ETL script
│
├── tests/                 # Unit tests
│   ├── test_data_cleaning.py
│   └── fixtures/          # Test data
│
├── .github/               # GitHub Actions CI
│   └── workflows/
│       └── ci.yml
│
├── Jenkinsfile           # Jenkins CI configuration
├── requirements.txt      # Python dependencies
├── pytest.ini           # Pytest configuration
└── README.md            # This file
```

## การติดตั้ง

1. Clone repository:
```bash
git clone <repository-url>
cd 2025-07-25
```

2. สร้าง virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. ติดตั้ง dependencies:
```bash
pip install -r requirements.txt
```

## การรัน ETL Pipeline

```bash
cd pre-production
python main.py
```

## การรัน Unit Tests

### รันทั้งหมด:
```bash
pytest tests/ -v
```

### รันเฉพาะ test_data_cleaning:
```bash
pytest tests/test_data_cleaning.py -v
```

### รันพร้อม coverage report:
```bash
pytest tests/ -v --cov=pre-production/etl --cov-report=html
```

## CI/CD Pipeline

### GitHub Actions
- **Trigger**: Push to main/develop หรือ Pull Request
- **Test Matrix**: Python 3.8, 3.9, 3.10
- **Features**:
  - Unit testing with pytest
  - Code coverage with codecov
  - Code linting with flake8
  - Artifact upload

### Jenkins
- **Features**:
  - Virtual environment isolation
  - Unit testing with HTML reports
  - Code coverage reports
  - Code quality checks (flake8, bandit)
  - Artifact archiving

### การตั้งค่า Jenkins:
1. สร้าง Pipeline job ใหม่
2. เลือก "Pipeline script from SCM"
3. ระบุ Git repository URL
4. Script path: `Jenkinsfile`

## Test Coverage

Test cases สำหรับ `clean_loan_data()`:
- ✅ การแทนที่ null ใน emp_length ด้วย 'N/A'
- ✅ การกรอง application_type '<NA>'
- ✅ การแปลง issue_d เป็น datetime
- ✅ การแปลง int_rate จาก % string เป็น float
- ✅ การรักษา data integrity
- ✅ Edge cases (empty dataframe, missing columns)

## Development Workflow

1. สร้าง feature branch:
```bash
git checkout -b feature/your-feature
```

2. พัฒนาและทดสอบ:
```bash
# แก้ไขโค้ด
# รัน tests
pytest tests/ -v
```

3. Commit และ push:
```bash
git add .
git commit -m "Add your feature"
git push origin feature/your-feature
```

4. สร้าง Pull Request
5. รอ CI pass
6. Merge เมื่อได้รับการ review

## ข้อกำหนดระบบ

- Python 3.8+
- SQL Server (สำหรับรัน ETL จริง)
- Git
- pip

## การแก้ปัญหา

### pytest import error:
```bash
# ตรวจสอบ PYTHONPATH
export PYTHONPATH="${PYTHONPATH}:${PWD}"
```

### Permission denied ใน Jenkins:
```bash
# ให้สิทธิ์ execute
chmod +x Jenkinsfile
```

## License

MIT License
