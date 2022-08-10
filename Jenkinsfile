pipeline {
    agent {label 'mo1833.gadi'}
    environment {
        DB_PATH = '/g/data/ik11/databases'
        DB_LINK = "${DB_PATH}/cosima_master.db"
        DB_DATE = """${sh(returnStdout: true, script: 'date +"%Y-%m-%d"')}""".trim()
        DB      = "${DB_PATH}/daily/cosima_master_${DB_DATE}.db"
    }
    stages {
        stage('Parallel stage') {
            parallel {
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
                             chmod 600 ${DB}'''

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
                stage('Check permissions') {
                    steps {
                        sh "./check_permissions"
                        script {
                            catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                                // We do the next check outside the bash script, so that we can catch the error and mark the build as unstable.
                                n_errors =  """${sh(returnStdout: true, script: 'wc -l incorrect_permissions')}""".trim()
                                if ("$n_errors"  != "0") {
                                    if ("""${sh(returnStdout: true, script: 'date +"%A"')}""".trim() == 'Monday') {
                                        emailext (
                                            subject: "Incorrect file permissions when indexing the COSIMA Cookbook database",
                                            to: '${FILE, path="blame_list"}',
                                            replyTo: 'micael.oliveira@anu.edu.au, andrew.kiss@anu.edu.au',
                                            body: 'Dear user,\n\n While updating the COSIMA Cookbook database, we found that several files that you own have incorrect permissions or they belong to the wrong group, which prevented us from adding them to the database. You can find the full list of files below (Note: It may be that you own only a subset of these files). We would be grateful if you could fix this issue by making sure that the group has read permissions for all files and directories, that the group has execute permissions for all directories, and that all files and directories belong to one of the following groups: ik11, hh5, or cj50.\nNote that this email is generated automatically. If you believe you have received this email by mistake, please contact Micael Oliveira (micael.oliveira@anu.edu.au) or Andrew Kiss (andrew.kiss@anu.edu.au).\n\nThe following files and/or directories have incorrect permissions:\n\n${FILE, path="incorrect_permissions"}',
                                        )
                                    }
                                    error "Some files and/or directories have incorrect permissions and/or wrong group"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    post {
        success {
            successfulDBUpdate()
        }
        unstable {
            successfulDBUpdate()
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
                to: 'micael.oliveira@anu.edu.au, andrew.kiss@anu.edu.au'
            )
        }
        cleanup {
            archiveArtifacts artifacts: "log, incorrect_permissions"
            cleanWs()
        }

    }
}

def successfulDBUpdate() {
    // Update was successful, so we can now update the symlink to point to this new version of the database
    sh "ln -sf ${DB} ${DB_LINK}"
    // Prune old versions of the database that have not been accessed in the last 14 days, making sure that we are left with at least 7 files.
    sh '''if [ $(find ${DB_PATH}/daily -type f -atime -14 -name cosima_master_????-??-??.db | wc -l) -gt 7 ]; then
              find ${DB_PATH}/daily -type f -atime +14 -name "cosima_master_????-??-??.db" -delete
          fi'''
}


def failedDBUpdate() {
    // Delete the failed attempt to update the database
    sh "rm -f ${DB}"
}
