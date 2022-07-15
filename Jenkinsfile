pipeline {
    agent {label 'mo1833.gadi'}
    environment {
        DB_PATH = '/scratch/v45/mo1833/databases'
        DB_LINK = "${DB_PATH}/cosima_master.db"
        DB_DATE = """${sh(returnStdout: true, script: 'date +"%Y-%m-%d"')}""".trim()
        DB      = "${DB_PATH}/daily/cosima_master_${DB_DATE}.db"
    }
    stages {
        stage('Update database') {
            steps {
                // Check if an update of the database has already been done today. Stop with an error if that is the case.
                script {
                    if (fileExists("${DB}")) {
                        error("Database has already been updated today.")
                    }
                }

                // Start the update from the latest version of the database
                sh '''cp ${DB_LINK} ${DB}
                      chmod 640 ${DB}'''

                // Try to update the database. Because the PBS job has a time limit, the update can fail for two different reasons:
                //  1. the time limit was reached
                //  2. an error occured
                // In the first case, we don't want to mark the build as failed, because the database will still be usable.
                script {
                    catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                       sh "qsub -v DB build_master_index"
                    }
                    if (currentBuild.result == 'UNSTABLE') {
                        // Check if the job hit the walltime. Mark the build as successful if that is the case.
                        timeout = """${sh(returnStdout: true, script: 'grep -c "PBS: job killed: walltime [0-9]* exceeded limit" log')}""".trim()
                        if ("$timeout"  == "1") {
                            echo "Database update timed out."
                            currentBuild.result == 'SUCCESS'
                        } else {
                            error "Error updating database."
                        }
                    }
                }

                sh """chmod 440 ${DB}
                      chgrp ik11 ${DB}"""
            }
        }
    }
    post {
        success {
            successulDBUpdate()
        }
        unstable {
            successulDBUpdate()
        }
        failure {
            failedDBUpdate()
        }
        aborted {
            failedDBUpdate()
        }
        unsuccessful {
            emailext (
                body: "${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
                subject: "Jenkins Build ${currentBuild.currentResult}: Job ${env.JOB_NAME}",
                to: 'micael.oliveira@anu.edu.au'
            )
        }
        cleanup {
            archiveArtifacts artifacts: "log"
            cleanWs()
        }

    }
}

def successulDBUpdate() {
    // Update was successful, so we can now update the symlink to point to this new version of the database
    sh "ln -sf ${DB} ${DB_LINK}"
    // Prune old versions of the database that have not been accessed in the last 14 days.
    sh 'find ${DB_PATH}/daily -type f -atime +14 -name "cosima_master_????-??-?.db" -exec rm -fv {} \\;'
}


def failedDBUpdate() {
    // Delete the failed attempt to update the database
    sh "rm -f ${DB}"
}
