Integration of #terraform with #jenkins.



In this project, I used Git, GitHub, DockerHub, Docker, Docker-compose, Jenkins (Shared Library - Credentials), Terraform (Provision Server, Remote State, S3), AWS, Linux commands, and Versioning App.



The following steps were taken:

- Created an SSH key pair for the EC2 instance.

- Created credentials in Jenkins.

- Installed Terraform inside the Jenkins container.

- Created Terraform configuration files to provision an EC2 server.

- Created an entry-script.sh file to install Docker, Docker-compose, and start containers through the Docker-compose command.

- Adjusted the Jenkinsfile to include the provision and deployment stage.

- Included Docker login to be able to pull Docker images from a private Docker repository.

- Successfully executed the CI/CD pipeline.



Great work on successfully integrating Terraform with Jenkins!
