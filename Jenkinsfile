pipeline {
     agent { label 'deploy' }
	 environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_ACCESS_KEY_SECRET = credentials('AWS_ACCESS_KEY_SECRET')
        ANSIBLE_VAULT_PASSWORD = credentials('ANSIBLE_VAULT_PASSWORD')
	 }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('Build') {
            steps {
                sh './docker/run.sh build'
            }
        }
        stage('Test'){
            when {
                expression {
                    env.BRANCH_NAME != 'master'
                }
            }
            steps {
                sh './docker/run.sh test'
            }
        }
        stage('Deploy') {
            when {
                expression {
                    env.BRANCH_NAME == 'master'
                }
            }
            steps {
                sh './docker/run.sh deploy'
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
