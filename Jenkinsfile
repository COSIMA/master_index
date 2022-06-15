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
                sh '''if [ -e ${DB_PATH}/${DB_NAME}_${DB_DATE}.db ]
                      then
                        echo "Cannot update database. File ${DB_PATH}/${DB_NAME}_${DB_DATE}.db already exist."
                        exit 1
                      else
                        cp -n ${DB_PATH}/${DB_NAME}.db ${DB_PATH}/${DB_NAME}_${DB_DATE}.db
                      fi'''
                sh "qsub -v DB_NAME,DB_PATH,DB_DATE build_master_index"
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

