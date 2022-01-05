ENVS_FILE = "monaco/05_exercise_five/environments.yaml"

pipeline {
    agent {
        label 'monaco-runner'
    }
    stages {
        stage('Dynatrace template - Validate') {
			steps {
                container('monaco') {
                    script{
                        sh "monaco -v -dry-run -e=$ENVS_FILE  monaco/05_exercise_five/template/"
                    }
                }
			}
		}
        stage('Dynatrace template - Deploy') {
			steps {
                container('monaco') {
                    script {
			sh "monaco -v -e=$ENVS_FILE monaco/05_exercise_five/template/"
                    }
                }
			}
		}    
    }
}
