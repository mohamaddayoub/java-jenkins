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
                    echo 'Deploying Docker image to EC2...'
                    def image = "mohamaddayoub/my-repo:$env.IMAGE_NAME"
                   
                    def shellCmd = "bash ./docker.Cmds.sh $image"
                    
                    def ec2Instance = "ec2-user@18.119.113.157"
                    

                    sshagent(['ec2-server']) {
                        
                        sh "scp -o StrictHostKeyChecking=no docker.Cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"

                    }

                }
            }
        }
        stage('commit version update') {
            steps {
                script {
                    sh "cd /var/jenkins_home/workspace/java-jenkins_main"
                    withCredentials([usernamePassword(credentialsId: 'GitLab-Credentials', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "git config --global --add safe.directory /var/jenkins_home/workspace/java-jenkins_main"
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'
                        echo "OK"
                        sh "git remote set-url origin https://${USER}:${PASS}@gitlab.com:mohamad.dayoubit/java-jenkins.git"
                        sh "git pull https://${USER}:${PASS}@gitlab.com:mohamad.dayoubit/java-jenkins.git main"  
                        sh 'git add .'
                        sh 'git commit -m "The version is updated"'
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }


    }
}
