// Agent labels
def zOsAgentLabel = env.ZOS_AGENT_LABEL ? env.ZOS_AGENT_LABEL : 'e2e-pipeline'
def linuxAgent = 'master'

// GIT repositories
def srcGitRepo =  null
def srcGitBranch = null
def zAppBuildGitRepo = 'https://github.com/IBM/dbb-zappbuild.git'
def zAppBuildGitBranch = 'development' // Some important issues are not yet merged into master.
def dbbGitRepo = 'https://github.com/jenkinsjby/dbb.git'
def dbbGitBranch = 'master'

// DBB
def dbbHome=null
def dbbUrl=null
def dbbHlq=null
def dbbBuildType='-i'
def dbbGroovyzOpts= ''
def dbbBuildExtraOpts= ''

// Artifactory
def artiCredentialsId = 'artifactory_id'


// UCD
def ucdApplication = 'GenApp-Deploy'
def ucdProcess = 'Deploy'
def ucdComponent = 'GenAppComponent'
def ucdEnv = 'Development'
def ucdSite = 'UrbanCodeE2EPipeline'

// Verbose
def verbose = env.VERBOSE && env.VERBOSE == 'true' ? true : false

// DCD
dcdServer= 'https://9.20.204.183:9443'
dcdCredId= 'dcd_id'
dcdScmClient= '/data/dcd/client/com.ibm.dcd.scmclient-1.1.0/scmclient.sh'

// ZCEE
def zceeCredId = 'e2e-sandbox-zcee'
// Private
def needDeploy = true
def buildVerbose = verbose ? '-v' : ''

@NonCPS
String getArtifactoruUrl(String artiUrl) {
    // UCD always add /artifactory
    def exp =  /(.*)\\/artifactory.*/
    def match = artiUrl =~ exp
    if (match.find()) {
        return match.group(1)
    }
    return artiUrl
}


pipeline {

    agent { label linuxAgent }

    options { skipDefaultCheckout(true) }

    stages {

        stage('Git Clone/Refresh') {
            agent { label zOsAgentLabel }
            steps {
                script {
                    if ( verbose ) {
                        echo sh(script: 'env|sort', returnStdout: true)
                    }

                    if ( env.DBB_HOME == null )
                        error("DBB_HOME is not defined !!!")
                    if ( env.DBB_URL == null )
                        error("DBB_URL is not defined !!!")
                    if ( env.DBB_HLQ == null )
                        error("DBB_HLQ is not defined !!!")
                    if ( env.ARTIFACTORY_URL == null )
                        error("ARTIFACTORY_URL is not defined !!!")
                    if ( env.ARTIFACTORY_REPO_PATH == null )
                        error("ARTIFACTORY_REPO_PATH is not defined !!!")
                    if ( env.UCD_BUZTOOL_PATH == null )
                        error("UCD_BUZTOOL_PATH is not defined !!!")

                    dir('cics-genapp') {
                        sh(script: 'rm -f .git/info/sparse-checkout', returnStdout: true)
                        srcGitRepo = scm.getUserRemoteConfigs()[0].getUrl()
                        srcGitBranch = scm.branches[0].name
                        def scmVars = null
                        scmVars = checkout([$class: 'GitSCM', branches: [[name: srcGitBranch]],
                                                doGenerateSubmoduleConfigurations: false,
                                                extensions: [
                                                [$class: 'SparseCheckoutPaths',
                                                   sparseCheckoutPaths:[[$class:'SparseCheckoutPath',
                                                   path:'cics-genapp/']]]
                                                ],
                                                submoduleCfg: [],
                                                userRemoteConfigs: [[
                                                                     // For now GenApp is not public
                                                                     credentialsId: 'ibm_git_hub',
                                                                     url: srcGitRepo,
                                                                     ]]])
                    }

                    dir("dbb-zappbuild") {
                        sh(script: 'rm -f .git/info/sparse-checkout', returnStdout: true)
                        def scmVars =
                            checkout([$class: 'GitSCM', branches: [[name: zAppBuildGitBranch]],
                              doGenerateSubmoduleConfigurations: false,
                              submoduleCfg: [],
                            userRemoteConfigs: [[
                                url: zAppBuildGitRepo,
                            ]]])
                    }

                    dir("dbb") {
                        sh(script: 'rm -f .git/info/sparse-checkout', returnStdout: true)
                        def scmVars =
                            checkout([$class: 'GitSCM', branches: [[name: dbbGitBranch]],
                              doGenerateSubmoduleConfigurations: false,
                              extensions: [
                                       [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[[$class:'SparseCheckoutPath', path:'Pipeline/CreateUCDComponentVersion/']]]
                                    ],
                              submoduleCfg: [],
                            userRemoteConfigs: [[
                                url: dbbGitRepo,
                            ]]])
                    }
                }
            }
        }

        stage('DBB Build') {
            steps {
                script{
                    node( zOsAgentLabel ) {
                        if ( env.DBB_BUILD_EXTRA_OPTS != null ) {
                           dbbBuildExtraOpts = env.DBB_BUILD_EXTRA_OPTS
                        }
                        if ( env.DBB_BUILD_TYPE != null ) {
                            dbbBuildType = env.DBB_BUILD_TYPE
                        }
                        if ( env.GROOVYZ_BUILD_EXTRA_OPTS != null ) {
                            dbbGroovyzOpts = env.GROOVYZ_BUILD_EXTRA_OPTS
                        }
                        dbbHome = env.DBB_HOME
                        dbbUrl = env.DBB_URL
                        dbbHlq = env.DBB_HLQ
                        sh "mkdir ${WORKSPACE}/BUILD-${BUILD_NUMBER}"
                        sh "chmod 777 ${WORKSPACE}/BUILD-${BUILD_NUMBER}"
                        sh "$dbbHome/bin/groovyz $dbbGroovyzOpts ${WORKSPACE}/dbb-zappbuild/build.groovy --logEncoding UTF-8 -w ${WORKSPACE} --application cics-genapp --sourceDir ${WORKSPACE}/cics-genapp  --workDir ${WORKSPACE}/BUILD-${BUILD_NUMBER} --hlq ${dbbHlq}.GENAPP --url $dbbUrl -pw ADMIN $dbbBuildType $buildVerbose $dbbBuildExtraOpts"
                        def files = findFiles(glob: "**BUILD-${BUILD_NUMBER}/**/buildList.txt")
                        // Do not deploy if nothing in the build list
                        needDeploy = files.length > 0 && files[0].length > 0
                    }
                }
            }
            post {
                always {
                    node( zOsAgentLabel ) {
                        dir("${WORKSPACE}/BUILD-${BUILD_NUMBER}") {
                            archiveArtifacts allowEmptyArchive: true,
                                            artifacts: '**/*.log,**/*.json,**/*.html',
                                            excludes: '**/*clist',
                                            onlyIfSuccessful: false
                        }
                    }
                }
            }
        }

        stage('DCD Build') {
            steps {
                script {
                           withCredentials([usernamePassword(credentialsId: dcdCredId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                                sh "$dcdScmClient --git --project cics-genapp --user $USERNAME --password $PASSWORD --server $dcdServer  --verbose ${WORKSPACE}@script"
                           }
               }
           }
        }

        stage('UCD Package') {
            steps {
                script {
                    node( zOsAgentLabel ) {
                        if ( needDeploy ) {
                            def artiUrl = getArtifactoruUrl(env.ARTIFACTORY_URL)
                            def repositoryPath = env.ARTIFACTORY_REPO_PATH
                            def ucdBuztool = env.UCD_BUZTOOL_PATH
                            BUILD_OUTPUT_FOLDER = sh (script: "ls ${WORKSPACE}/BUILD-${BUILD_NUMBER}", returnStdout: true).trim()
                            dir("${WORKSPACE}/BUILD-${BUILD_NUMBER}/${BUILD_OUTPUT_FOLDER}") {
                                withCredentials([usernamePassword(credentialsId: artiCredentialsId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                                    writeFile file: "${WORKSPACE}/BUILD-${BUILD_NUMBER}/artifactoy.properties", encoding: "ibm-1047",
                                       text:"""password=$PASSWORD
username=$USERNAME
Repository_type=artifactory
repository=${repositoryPath}
url=${artiUrl}
                                      """
                                }
                                sh "$dbbHome/bin/groovyz $dbbGroovyzOpts ${WORKSPACE}/dbb/Pipeline/CreateUCDComponentVersion/dbb-ucd-packaging.groovy --buztool ${ucdBuztool} --component ${ucdComponent} --workDir ${WORKSPACE}/BUILD-${BUILD_NUMBER}/${BUILD_OUTPUT_FOLDER} --artifactRepository ${WORKSPACE}/BUILD-${BUILD_NUMBER}/artifactoy.properties  --versionName BUILD-${BUILD_NUMBER}"
                            }
                        }
                    }
                }
            }
        }

        stage('UCD Deploy') {
            steps {
                script{
                    if ( needDeploy ) {
                        script{
                            step(
                                  [$class: 'UCDeployPublisher',
                                    deploy: [
                                        deployApp: ucdApplication,
                                        deployDesc: 'Requested from Jenkins',
                                        deployEnv: ucdEnv,
                                        deployOnlyChanged: false,
                                        deployProc: ucdProcess,
                                        deployVersions: ucdComponent + ':latest'],
                                    siteName: ucdSite])
                        }
                    }
                }
            }
        }
        stage ('Integration Tests'){
             steps {
                   script{
                       node( zOsAgentLabel ) {
                           withCredentials([usernamePassword(credentialsId: zceeCredId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                                // Very basic for now
                                sh "curl -k -u $USERNAME:$PASSWORD -H 'Content-Type:application/json' -X GET $ZCEE_URL/genapp/motorPolicy/2/1 > ${WORKSPACE}/BUILD-${BUILD_NUMBER}/api.log"
                                sh "grep '1999-01-01'  ${WORKSPACE}/BUILD-${BUILD_NUMBER}/api.log"
                            }
                        }
                  }
             }
        }
    }
}