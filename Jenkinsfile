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
                    echo 'starting.....'
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
                    buildImage 'mohamaddayoub/my-repo:1.1.3'
                    dockerLogin()
                    dockerPush 'mohamaddayoub/my-repo:1.1.3'
                }
            }
        }
        
        stage("deploy") {
            steps {
                script {
                    echo "deploy...."
                     }
                 }
    }
}}
