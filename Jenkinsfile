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
                sh '''cp -n ${DB_PATH}/${DB_NAME}.db ${DB_PATH}/${DB_NAME}_${DB_DATE}.db
                      chmod 640 ${DB_PATH}/${DB_NAME}_${DB_DATE}.db'''

                script {
                    Exception caughtException = null

                    catchError(catchInterruptions: 'TRUE', buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        try {
                            timeout(time: 6, unit: "HOURS") {
                                sh "./build_master_index"
                            }
                        } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException e) {
                            error "Caught ${e.toString()}"
                        } catch (Throwable e) {
                            caughtException = e
                        }
                    }

                    if (caughtException) {
                        error caughtException.message
                    }
                }
            }
        }
    }
    post {
        success {
            sh "ln -sf ${DB_PATH}/${DB_NAME}_${DB_DATE}.db ${DB_PATH}/${DB_NAME}.db"
        }
        unstable {
            sh "ln -sf ${DB_PATH}/${DB_NAME}_${DB_DATE}.db ${DB_PATH}/${DB_NAME}.db"
        }
        unsuccessful {
            emailext (
                body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}",
                to: 'micael.oliveira@anu.edu.au'
            )
        }
        cleanup {
            sh "chmod 440 ${DB_PATH}/${DB_NAME}_${DB_DATE}.db"
            sh "find ${DB_PATH}/${DB_NAME}_????-??-??.db -type f -atime +14 -exec rm {} \\;"
            cleanWs()
        }

    }
}
