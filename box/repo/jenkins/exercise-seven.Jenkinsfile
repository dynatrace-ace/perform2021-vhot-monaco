ENVS_FILE = "monaco/07_exercise_seven/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace linked config - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE monaco/07_exercise_seven/projects/"
                    }
                }
			}
		}
        stage('Dynatrace linked config - Deploy') {
			steps {
                container('monaco') {
                    script {
				        sh "monaco -v -e=$ENVS_FILE monaco/07_exercise_seven/projects/"
                    }
                }
			}
		}       
    }
}