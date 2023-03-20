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
        
    
        stage('deploy') {
            steps {
                script {
                    echo 'Deploying Docker image to EC2...'
                    def image = "mohamaddayoub/my-repo:$env.IMAGE_NAME"
                   
                    def shellCmd = "bash ./docker.Cmds.sh $image"
                    
                    def ec2Instance = "ec2-user@3.144.255.198"
                    

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
		      catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
			withCredentials([usernamePassword(credentialsId: 'GitHub-Credentials', passwordVariable: 'PASS', usernameVariable: 'USR')]) {
			    def encodedPassword = URLEncoder.encode("$PASS",'UTF-8')
			    sh 'git config user.email "jenkins@example.com" '
			    sh 'git config user.name "jenkins" '
			    sh "git add ."
			    sh "git commit -m 'Triggered Build: ${env.BUILD_NUMBER}'"
			    sh "git push https://${USR}:${encodedPassword}@github.com/${USR}/java-jenkins.git"
			}
		      }
		    }
  		}
		
       	 
    }
}
