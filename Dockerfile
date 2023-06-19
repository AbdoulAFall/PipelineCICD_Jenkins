#Grab the latest alpine image
FROM nginx:1.21.1
 
LABEL maintainter="AbdoulAFall" email="abdoulazizfall2@gmail.com"

RUN apt-get uppdate && \
    apt-get upgrade -y && \
    apt-get install -y curl && \
    apt-get install -y git 
    
RUN rm -Rf /usr/share/nginx/html/*
RUN git clone https://github.com/diranetafen/static-website-example.git /usr/share/nginx/html/

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku			
CMD gunicorn --bind 0.0.0.0:$PORT wsgi 