# Voyent Freight Demo

# This container is based on our Polymer Base image.  It then copies over
# and builds the app and sets it to be served via Nginx.

# The name:version of the Docker image to use.  Must be the first non-comment.
FROM voyent/base-polymer:latest

MAINTAINER ICEsoft Technologies, Inc.

# Currently, npm default logging for the official Node docker container has
# logging set to "info" which results in a lot of information being dumped.
# We turn it down by setting this but if you need more logging, comment
# this out before rebuilding the image.
ENV NPM_CONFIG_LOGLEVEL warn

# Set our working directory.
RUN mkdir /work
WORKDIR /work

#Gulp gets installed locally under this path during 'npm install'
ENV PATH $PATH:/work/node_modules/.bin/

COPY package.json ./
RUN npm install

COPY *.json ./
COPY .bowerrc ./
COPY .eslintignore ./
COPY .jscsrc ./
COPY .jshintrc ./
COPY gulpfile.js ./

RUN bower install

COPY app ./app
COPY docs ./docs
COPY tasks ./tasks

RUN gulp

# Remove the Unix-y tools.
RUN apt-get remove -q -y curl xz-utils git-all

# Copy our custom nginx configurations.
COPY nginx.conf /etc/nginx/nginx.conf
COPY default /etc/nginx/conf.d/default.conf

# Copy the contents of the built version of the console so that nginx can serve it.
# A couple of notes.  After making the directory, we list it.  Seems to be a weird
# workaround to ensure that the director actually exists before we move stuff into
# it.  I was getting errors during the "mv" command otherwise.
RUN ["mkdir", "-p", "/usr/share/nginx/html/demos"]
RUN ["ls", "-la", "/usr/share/nginx/html/demos"]
RUN ["mv", "./dist", "/usr/share/nginx/html/demos/freight"]

# Clean up by removing the work directory that has all the build artifacts.
WORKDIR /
RUN ["rm", "-Rf", "/work"]

