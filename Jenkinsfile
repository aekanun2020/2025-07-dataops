pipeline {
    agent any
    
    options {
        // Keep only 10 builds
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }
    
    environment {
        // Python virtual environment
        VENV = "${WORKSPACE}/venv"
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace before checkout
                cleanWs()
                checkout scm
            }
        }
        
        stage('Setup Python Environment') {
            steps {
                script {
                    // Create virtual environment
                    sh '''
                        python3 -m venv ${VENV}
                        . ${VENV}/bin/activate
                        pip install --upgrade pip
                    '''
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    sh '''
                        . ${VENV}/bin/activate
                        pip install -r requirements.txt
                        pip install pytest pytest-cov pytest-html
                    '''
                }
            }
        }
        
        stage('Run Unit Tests') {
            steps {
                script {
                    sh '''
                        . ${VENV}/bin/activate
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
    }
    
    post {
        always {
            // Archive test results
            archiveArtifacts artifacts: 'test-results/**/*', allowEmptyArchive: true
            
            // Publish test results
            junit 'test-results/junit.xml'
            
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
            
            // Clean workspace
            cleanWs()
        }
        
        success {
            echo 'Pipeline completed successfully!'
        }
        
        failure {
            echo 'Pipeline failed!'
            // Send notification if needed
        }
    }
}
