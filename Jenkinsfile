pipeline {
    agent {
        docker {
            image 'python:3.8'
            args '-v /tmp:/tmp'
        }
    }
    
    options {
        // Keep only 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    stages {
        stage('Setup') {
            steps {
                echo 'Setting up Python environment...'
                sh '''
                    python --version
                    pip install --upgrade pip
                '''
            }
        }
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing dependencies...'
                sh '''
                    pip install -r requirements.txt
                    pip install pytest pytest-cov pytest-html
                '''
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                echo 'Running tests...'
                sh '''
                    pytest tests/test_data_cleaning.py \
                        -v \
                        --junitxml=test-results/junit.xml \
                        --html=test-results/pytest-report.html \
                        --self-contained-html \
                        --cov=pre-production/etl \
                        --cov-report=xml:test-results/coverage.xml \
                        --cov-report=html:test-results/htmlcov
                '''
            }
        }
    }
    
    post {
        always {
            // Archive test results
            archiveArtifacts artifacts: 'test-results/**/*', allowEmptyArchive: true
            
            // Publish test results
            junit allowEmptyResults: true, testResults: 'test-results/junit.xml'
            
            // Publish HTML reports
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'test-results',
                reportFiles: 'pytest-report.html',
                reportName: 'Pytest Report'
            ])
            
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'test-results/htmlcov',
                reportFiles: 'index.html',
                reportName: 'Coverage Report'
            ])
        }
        
        success {
            echo 'Pipeline completed successfully!'
        }
        
        failure {
            echo 'Pipeline failed!'
        }
    }
}
