ENVS_FILE = "monaco/04_exercise_four/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace global config - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=global monaco/04_exercise_four/projects/"
                    }
                }
			}
		}
        stage('Dynatrace global config - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=global monaco/04_exercise_four/projects/"
                        sh "sleep 60"
                    }
                }
			}
		}       
        stage('Dynatrace Perform project - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE -p=perform monaco/04_exercise_four/projects/"
                    }
                }
			}
		}
        stage('Dynatrace Perform project - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE -p=perform monaco/04_exercise_four/projects/"
                    }
                }
			}
		}       
    }
}