// Agents Labels
def linuxAgent = 'master'
def zOsAgentLabel = env.ZOS_AGENT_LABEL ? env.ZOS_AGENT_LABEL : 'e2e-pipeline'

// DBB
def dbbHlq = 'NAZARE.DCD'
def dbbDaemonPort = null
def dbbGroovyzOpts= ''
def dbbBuildType='-i'
def dbbBuildExtraOpts=''

// GIT
def gitCredId = 'e2e-sandbox-sshsecret'
def gitOrg = 'IBMZSoftware'
def gitHost = 'github.ibm.com'
def srcGitRepo =   'git@'+gitHost+':'+gitOrg+'/cics-genapp.git'
def adminGitRepo = 'git@'+gitHost+':'+gitOrg+'/nazare-demo-sysadmin.git'
def adminGitBranch = 'openshift'
def srcGitBranch = 'openshift'


// Artifactory
def serverId = "ArtifactoryE2EPipeline"
def server = Artifactory.server serverId
def artiCredentialsId = 'e2e-sandbox-artifactory'
def repository = "sys-nazare-sysadmin-generic-local"
def repositoryFolder = "cics-genapp/dcd"
def repositoryPath = repository + "/" + repositoryFolder

// ZCEE
zceeCredId= 'e2e-sandbox-zcee'

// DCD
dcdServer= 'https://127.0.0.1:9443'
dcdCredId= 'e2e-sandbox-dcd'
dcdScmClient= '/data/dcd/client/com.ibm.dcd.scmclient-1.0.2/scmclient.sh'

// Verbose
def verbose = env.VERBOSE && env.VERBOSE == 'true' ? true : false

// Private
def needDeploy = true
def buildVerbose = verbose ? '-v' : ''
def appName = null
def appVersion = null
 

pipeline {

    agent { label linuxAgent }

    options { skipDefaultCheckout(true) }

    stages {
        stage('Git Clone/Refresh') {
            agent { label zOsAgentLabel }
            steps {
                script {
                    catchError(buildResult: 'SUCCESS', stageResult: 'SUCCESS'){
                        srcGitRepo = scm.getUserRemoteConfigs()[0].getUrl()
                        srcGitBranch = scm.branches[0].name
                    }
                    println "URL is   : $srcGitRepo"
                    println "Branch is: $srcGitBranch"
                    sh(script: "rm -rf ${WORKSPACE}/BUILD-${BUILD_NUMBER}", returnStdout: true)
                    if ( verbose ) {
                        echo sh(script: 'env|sort', returnStdout: true)
                    }
                    if ( env.PROJECT_NAME ) {
                      gitCredId = env.PROJECT_NAME + '-sshsecret'
                    }
                    dir('cics-genapp') {
                        def scmVars = null
                        // Root location of the groovy script.
                        env.WORKSPACE_ROOT = "${WORKSPACE}".substring(0, "${WORKSPACE}".lastIndexOf('/')) + "/" + gitOrg + "/" + adminGitBranch
                        sh(script: 'rm -f .git/info/sparse-checkout', returnStdout: true)
                        scmVars = checkout([$class: 'GitSCM', branches: [[name: srcGitBranch]],
                                                doGenerateSubmoduleConfigurations: false,
                                                submoduleCfg: [],
                                                extensions: [
                                                             [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[
                                                                     [$class:'SparseCheckoutPath', path:'base/src/'],
                                                                     [$class:'SparseCheckoutPath', path:'application-conf/'],
                                                                     [$class:'SparseCheckoutPath', path:'deploy-conf/']
                                                                     ]]
                                                                     ],
                                                userRemoteConfigs: [[
                                                                     credentialsId: gitCredId,
                                                                     url: srcGitRepo,
                                                                     ]]])

                        env.GIT_COMMIT_DEMO_GENAPP =  scmVars.GIT_COMMIT
                        env.GIT_URL_DEMO_GENAPP =  scmVars.GIT_URL
                    }
                    
                    dir("${env.WORKSPACE_ROOT}/nazare-demo-sysadmin") {
                    sh(script: 'rm -f .git/info/sparse-checkout', returnStdout: true)
                    def scmVars =
                        checkout([$class: 'GitSCM', branches: [[name: adminGitBranch]],
                              doGenerateSubmoduleConfigurations: false,
                              submoduleCfg: [],
                              extensions: [
                                       [$class: 'SparseCheckoutPaths',  sparseCheckoutPaths:[
                                                                   [$class:'SparseCheckoutPath', path:'zAppBuild/'],
                                                                   [$class:'SparseCheckoutPath', path:'Pipeline/']
                                                                 ]]
                                    ],
                            userRemoteConfigs: [[
                                credentialsId: gitCredId,
                                url: adminGitRepo,
                            ]]])
                    }
                }
            }
        }

        stage('DBB Build') {
            steps {
                script{
                    node( zOsAgentLabel ) {
                        if ( env.DBB_BUILD_TYPE != null ) {
                            dbbBuildType = env.DBB_BUILD_TYPE;
                        }
                        if ( env.DBB_BUILD_EXTRA_OPTS != null ) {
                           dbbBuildExtraOpts = env.DBB_BUILD_EXTRA_OPTS
                        }
                        if ( env.GROOVYZ_BUILD_EXTRA_OPTS != null ) {
                           dbbGroovyzOpts = env.GROOVYZ_BUILD_EXTRA_OPTS
                        }
                        if ( env.DBB_DAEMON_PORT != null ) {
                            dbbDaemonPort = env.DBB_DAEMON_PORT;
                        }
                        if ( dbbDaemonPort != null ) {
                            def r = sh script: "netstat | grep ${dbbDaemonPort}", returnStatus: true
                            if ( r == 0 ) {
                                println "DBB Daemon is running.."
                                dbbGroovyzOpts += " -DBB_DAEMON_PORT ${dbbDaemonPort} -DBB_DAEMON_HOST 127.0.0.1"
                                sh "mkdir ${WORKSPACE}/BUILD-${BUILD_NUMBER}"
                                sh "chmod 777 ${WORKSPACE}/BUILD-${BUILD_NUMBER}"
                            }
                            else {
                                println "WARNING: DBB Daemon not running build will be longer.."
                                currentBuild.result = "UNSTABLE"
                            }
                        }
                        
                        sh "$DBB_HOME/bin/groovyz $dbbGroovyzOpts ${WORKSPACE_ROOT}/nazare-demo-sysadmin/zAppBuild/build.groovy\
                                --logEncoding UTF-8 -w ${WORKSPACE} --application cics-genapp --sourceDir ${WORKSPACE}\
                                --workDir ${WORKSPACE}/BUILD-${BUILD_NUMBER}  --hlq ${dbbHlq}.GENAPP --url $DBB_URL -pw ADMIN $dbbBuildType $dbbBuildExtraOpts $buildVerbose"
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
        
        stage('DCD Scan/Update') {
            steps {
                script {
                           withCredentials([usernamePassword(credentialsId: dcdCredId, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                                sh "$dcdScmClient --git --project GenApp --user $USERNAME --password $PASSWORD --server $dcdServer  --verbose ${WORKSPACE}@script/base"
                           }
               }
           }
        }
        
        stage('Package') {
            steps {
                script {
                    node( zOsAgentLabel ) { 
                        if ( needDeploy ) {
                            BUILD_OUTPUT_FOLDER = sh (script: "ls ${WORKSPACE}/BUILD-${BUILD_NUMBER} | grep \"build.*[0-9]\$\" | tail -n 1", returnStdout: true).trim()
                            dir("${WORKSPACE}/BUILD-${BUILD_NUMBER}/${BUILD_OUTPUT_FOLDER}") {
                                if ( env.PROJECT_NAME ) {
                                    artiCredentialsId = env.PROJECT_NAME + '-artifactory'
                                }
                                server.credentialsId = artiCredentialsId
                                sh "$DBB_HOME/bin/groovyz $dbbGroovyzOpts ${WORKSPACE_ROOT}/nazare-demo-sysadmin/Pipeline/Zar/Package.groovy\
                                       -a ${WORKSPACE}/cics-genapp/application-conf\
                                       -s ${WORKSPACE}/cics-genapp\
                                       -b ${WORKSPACE_ROOT}/nazare-demo-sysadmin\
                                       -w ${WORKSPACE}/BUILD-${BUILD_NUMBER}/${BUILD_OUTPUT_FOLDER}\
                                       -hl ${dbbHlq}.GENAPP\
                                       -n ${BUILD_NUMBER}\
                                       -r ${server.url}/${repositoryPath}"
                                       
                                def fileContents = readFile file: "${WORKSPACE}/cics-genapp/application-conf/app.yaml", encoding: "IBM-1047"
                                def datas = readYaml text: fileContents
                                appName = datas['name']
                                appVersion = datas['version']
                                println "Artifactory publish url: ${server.url}/${repositoryPath}/${appVersion}/${srcGitBranch}/${BUILD_NUMBER}/${appName}-${appVersion}.tar"
                                def pattern = "${appName}-${appVersion}.tar"
                                def target = "${repositoryPath}/${appVersion}/${srcGitBranch}/${BUILD_NUMBER}/"
                               uploadToArtifactory(server, pattern, target)
                            }
                        }
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                script{
                    node( zOsAgentLabel ) { 
                        if ( needDeploy ) {
                            if ( env.PROJECT_NAME ) {
                                    artiCredentialsId = env.PROJECT_NAME + '-artifactory'
                            }
                            server.credentialsId = artiCredentialsId
                            def deployInputFile = "deploy.${zOsAgentLabel}.yaml"
                            if ( env.DEPLOY_INPUT_FILE ) {
                                    deployInputFile = env.DEPLOY_INPUT_FILE
                            }
                            def pattern = "${repositoryPath}/${appVersion}/${srcGitBranch}/${BUILD_NUMBER}/*"
                            def target = "${WORKSPACE}/BUILD-${BUILD_NUMBER}/tempDownload/"
                            sh "mkdir -p ${WORKSPACE}/BUILD-${BUILD_NUMBER}/tempDownload"
                            downloadFromArtifactory(server, pattern, target)
                            sh "$DBB_HOME/bin/groovyz $dbbGroovyzOpts ${WORKSPACE_ROOT}/nazare-demo-sysadmin/Pipeline/Zar/CicsDeploy.groovy\
                                   -w ${WORKSPACE}/BUILD-${BUILD_NUMBER}\
                                   -t ${WORKSPACE}/BUILD-${BUILD_NUMBER}/tempDownload/"+ $repositoryFolder + "/${appVersion}/${srcGitBranch}/${BUILD_NUMBER}/${appName}-${appVersion}.tar\
                                   -y ${WORKSPACE}/cics-genapp/deploy-conf/${deployInputFile} $buildVerbose"
                            
                        }
                    }
                }
            }
            post {
                always {
                    node( zOsAgentLabel ) {
                        dir("${WORKSPACE}/BUILD-${BUILD_NUMBER}") {
                            archiveArtifacts allowEmptyArchive: true, 
                                            artifacts: '*_bind.log,*_refresh.log', 
                                            onlyIfSuccessful: false
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

// Artifactory upload
void uploadToArtifactory(server, pattern, target){
    def buildInfo = server.upload  spec:
            """{
                "files": [
                    {
                        "pattern": "${pattern}",
                        "target": "${target}"
                    }
                    ]
            }"""
            
    // Publish the build info to Artifactory
    server.publishBuildInfo buildInfo
}

// Artifactory download
void downloadFromArtifactory(server, pattern, target){
    server.download  spec:
            """{
                    "files": [
                            {
                                "pattern": "${pattern}",
                                "target": "${target}"
                            }
                        ]
            }"""
}
