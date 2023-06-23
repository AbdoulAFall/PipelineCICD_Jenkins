pipeline {
     environment {
       IMAGE_NAME = "static-website-example"
       IMAGE_TAG = "latest"
       STAGING = "abdoulafall-staging"
       PRODUCTION = "abdoulafall-production"
       APP_EXPOSED_PORT = 80
       APP_CONTAINER_PORT = 5000

     }
     agent none
     stages {
         stage('Build image') {
             agent any
             steps {
                script {
                  sh 'docker build -t abdoulafall/$IMAGE_NAME:$IMAGE_TAG .'
                }
             }
        }
        stage('Run container based on builded image') {
            agent any
            steps {
               script {
                 sh '''
                    echo "Cleaning existing container if exist"
                    docker ps -a | grep -i $IMAGE_NAME && docker rm -f $IMAGE_NAME
                    docker run --name $IMAGE_NAME -d -p $APP_EXPOSED_PORT:$APP_CONTAINER_PORT -e PORT=$APP_CONTAINER_PORT abdoulafall/$IMAGE_NAME:$IMAGE_TAG
                    sleep 5
                    docker ps -a
                 '''
               }
            }
       }
       stage('Test image') {
           agent any
           steps {
              script {
                sh '''
                    curl http://localhost:80 | grep -q "Dimension"
                '''
              }
           }
      }
      stage('Clean Container') {
          agent any
          steps {
             script {
               sh '''
                 docker stop $IMAGE_NAME
                 docker rm $IMAGE_NAME
               '''
             }
          }
     }
     stage('Push image in staging and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/main' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $STAGING || echo "project already exist"
              heroku container:push -a $STAGING web
              heroku container:release -a $STAGING web
            '''
          }
        }
     }
     stage('Push image in production and deploy it') {
       when {
              expression { GIT_BRANCH == 'origin/main' }
            }
      agent any
      environment {
          HEROKU_API_KEY = credentials('heroku_api_key')
      }  
      steps {
          script {
            sh '''
              heroku container:login
              heroku create $PRODUCTION || echo "project already exist"
              heroku container:push -a $PRODUCTION web
              heroku container:release -a $PRODUCTION web
            '''
          }
        }
     }
  }
  post {
       success {
         slackSend (color: '#00FF00', message: "SUCCESSFUL: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
         }
      failure {
            slackSend (color: '#FF0000', message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})")
          }   
    }
}