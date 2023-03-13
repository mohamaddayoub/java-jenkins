#!/usr/bin/env groovy

library identifier: 'jenkins-shared@main', retriever: modernSCM(
        [
                $class: 'GitSCMSource',
                remote: 'https://gitlab.com/mohamad.dayoubit/jenkins-shared.git',
                credentialsId: 'GitLab-Credentials'
        ]
)

pipeline {
    agent any
    tools {
	    maven 'Maven'
	}
    
    stages {
        stage('Increment Version') {
            steps {
                script {
                    echo "Incrementing App Version....."
                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.nextMajorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.incrementalVersion} versions:commit"
                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = matcher[0][1]
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"

                }
            }
        }

        stage("build jar") {
            steps {
                script {
                    buildJar()
                }
            }
        }
        stage("build Image") {
            steps {
                script {
                    buildImage "mohamaddayoub/my-repo:${IMAGE_NAME}"
                    dockerLogin()
                    dockerPush "mohamaddayoub/my-repo:${IMAGE_NAME}"
                }
            }
        }
        
    
        stage('deploy') {
            steps {
                script {
                    echo 'deploying docker image to EC2...'
                    def IMAGE = "mohamaddayoub/my-repo:${IMAGE_NAME}"
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE}"
                    def ec2Instance = "ec2-user@18.119.113.157"

                    sshagent(['ec2-server']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }

    }
}
