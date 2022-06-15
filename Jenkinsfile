pipeline {
    agent {label 'mo1833.gadi'}
    environment {
        DB_PATH = '/scratch/v45/mo1833/databases'
        DB_NAME = 'cosima_master'
        DB_DATE = """${sh(returnStdout: true, script: 'date +"%Y-%m-%d"')}""".trim()
    }
    stages {
        stage('Update database') {
            steps {
                sh "cp -n ${DB_PATH}/${DB_NAME}.db ${DB_PATH}/${DB_NAME}_${DB_DATE}.db"
                sh "chmod 640 ${DB_PATH}/${DB_NAME}_${DB_DATE}.db"
                sh "qsub -v DB_NAME,DB_PATH,DB_DATE build_master_index"
                sh "chmod 440 ${DB_PATH}/${DB_NAME}_${DB_DATE}.db"
            }
        }
        stage('Update symlink') {
            steps {
                sh "ln -sf ${DB_PATH}/${DB_NAME}_${DB_DATE}.db ${DB_PATH}/${DB_NAME}.db"
            }
        }       
        stage('Prune old copies') {
            steps {
                sh "find ${DB_PATH}/${DB_NAME}_????-??-??.db -type f -atime +14 -exec rm {} \\;"
            }
        }
    }
}

