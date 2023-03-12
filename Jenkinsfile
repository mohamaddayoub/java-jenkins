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
        stage("incrementing version") {
            steps {
                script {
                    incrementVersion()
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
                    buildImage "mohamaddayoub/my-repo:$IMAGE_NAME"
                    dockerLogin()
                    dockerPush "mohamaddayoub/my-repo:$IMAGE_NAME"
                }
            }
        }
        
        stage("deploy") {
            steps {
                script {
                    deployEC2()
                     }
                 }
    }
}}
