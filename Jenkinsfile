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
                    echo 'starting....'
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
                    buildImage()
                    dockerLogin()
                    dockerPush()
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
