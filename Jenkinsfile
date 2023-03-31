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
                    echo "Incrementing Application Version......"
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
        
        stage('provision server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('aws-ak	')
                AWS_SECRET_ACCESS_KEY = credentials('aws-sak')
                TF_VAR_environment = "test"
            }
            steps {
                script {
                    dir('terraform') {  
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
    
        stage('deploy') {
            environment {
                DOCKER_CREDS = Credentials('DockerHub-Credentials')
            }

            steps {
                script {
                    echo "waiting for EC2 server to initialize" 
                    sleep(time: 90, unit: "SECONDS")

                    echo 'Deploying Docker image to EC2...'
                    echo "${EC2_PUBLIC_IP} is the public IP for the server"

                    def image = "mohamaddayoub/my-repo:$env.IMAGE_NAME"                  
                    def shellCmd = "bash ./docker.Cmds.sh $image ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"                 
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}" 

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
			withCredentials([string(credentialsId: 'GitHubToken', variable: 'PASS')]) {    
			    sh 'git config --global user.email "jenkins@example.com"'
			    sh 'git config --global user.name "Jenkins"'
			    sh 'git add .'
			    sh 'git commit -m "Jenkins commit"'
			    sh 'git push -u https://mohamaddayoub:${PASS}@github.com/mohamaddayoub/java-jenkins.git HEAD:main'
			}
		      }
		    }
  		
  	  }
	}
}
