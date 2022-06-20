pipeline {
    agent {label 'mo1833.gadi'}
    environment {
        DB_PATH = '/scratch/v45/mo1833/databases'
        DB_DATE = """${sh(returnStdout: true, script: 'date +"%Y-%m-%d"')}""".trim()
        DB_NEW = "${DB_PATH}/daily/cosima_master_${DB_DATE}.db"
        DB_LINK = "${DB_PATH}/cosima_master.db"
    }
    stages {
        stage('Update database') {
            steps {
                // Check if an update of the database has already been done today. Stop with an error if that is the case.
                script {
                    if (fileExists("${DB_NEW}")) {
                        error("Database has already been updated today.")
                    }
                }

                // Start the update from the latest version of the database
                sh '''cp ${DB_LINK} ${DB_NEW}
                      chmod 640 ${DB_NEW}'''

                // Try to update the database. The logic of the next block is unfortunately not easy to follow.
                // Because we set a time limit, the update can fail for two different reasons:
                //  1. the time limit was reached
                //  2. an error occured
                // In the first case, we don't want to mark the build as failed, because the database will still be usable.
                // Therfore we need to catch the error, so that we can transform it from "ABORTED" to "UNSTABLE".
                // For the second case, we use cauthtException to record that an error occured and throw the error afterwards
                // (catchError will, as its name suggest, catch that error, so another strategy is needed to get the build to fail).
                script {
                    Exception caughtException = null

                    catchError(catchInterruptions: 'TRUE', buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                        try {
                            timeout(time: 6, unit: "HOURS") {
                                sh "./build_master_index ${DB_NEW}"
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

                sh "chmod 440 ${DB_NEW}"
            }
        }
    }
    post {
        success {
            // Update was successful, so we can now update the symlink to point to this new version of the database
            sh "ln -sf ${DB_NEW} ${DB_LINK}"
        }
        unstable {
            // The update timed out, but since no other errors have occured, this database should be usable and more complete than the previous version.
            sh "ln -sf ${DB_NEW} ${DB_LINK}"
        }
        failure {
            // Delete the failed attempt to update the database
            sh "rm -f ${DB_NEW}"
        }
        aborted {
            // Delete the failed attempt to update the database, as we cannot be sure about the state of the database in that case
            sh "rm -f ${DB_NEW}"
        }
        unsuccessful {
            emailext (
                body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}",
                to: 'micael.oliveira@anu.edu.au'
            )
        }
        cleanup {
            // Prune old versions of the database that have not been accessed in the last 14 days.
            sh 'find ${DB_PATH}/daily -type f -atime +14 -exec rm -fv {} \\;'
            cleanWs()
        }

    }
}
