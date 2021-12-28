ENVS_FILE = "monaco/02_exercise_two/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace global config - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects/"
                    }
                }
			}
		}
        stage('Dynatrace global config - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=global monaco/02_exercise_two/projects/"
                        sh "sleep 60"
                    }
                }
			}
		}       
        stage('Dynatrace Perform project - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=perform monaco/02_exercise_two/projects/"
                    }
                }
			}
		}
        stage('Dynatrace Perform project - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=perform monaco/02_exercise_two/projects/"
                    }
                }
			}
		}       
    }
}