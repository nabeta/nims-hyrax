FROM ruby:2.6

# Setup build variables
ARG RAILS_ENV
ARG DERIVATIVES_PATH
ARG UPLOADS_PATH
ARG CACHE_PATH
ARG AIRBRAKE_HOST
ARG AIRBRAKE_PROJECT_ID
ARG AIRBRAKE_PROJECT_KEY

ENV APP_PRODUCTION=/data/ \
    APP_WORKDIR=/data

# Add backports to apt-get sources
# Install libraries, dependencies, java and fits

RUN echo 'deb  http://deb.debian.org/debian stretch main contrib non-free'
RUN echo 'deb-src  http://deb.debian.org/debian stretch main contrib non-free'

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev \
    libxml2-dev libxslt1-dev \
    nodejs \
    libreoffice \
    libass-dev libfreetype6-dev libmp3lame-dev libopus-dev libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev \
    libvpx-dev libvorbis-dev libx264-dev libx265-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev nasm pkg-config \
    texinfo wget yasm zlib1g-dev fonts-ipaexfont fonts-ipafont fonts-vlgothic \
    libjpeg-dev libtiff-dev libpng-dev libraw-dev libwebp-dev libjxr-dev \
    libcairo2-dev libgs-dev librsvg2-dev \
    libmp3lame-dev libvorbis-dev libtheora-dev libspeex-dev libx264-dev libav-tools \
    ghostscript ffmpeg imagemagick \
    ufraw \
    bzip2 unzip xz-utils \
    vim \
    git \
    openjdk-8-jre-headless

RUN mkdir -p /fits/ \
    && wget -q https://projects.iq.harvard.edu/files/fits/files/fits-1.3.0.zip -O /fits/fits-1.3.0.zip \
    && unzip -q /fits/fits-1.3.0.zip -d /fits/fits-1.3.0 \
    && chmod a+x /fits/fits-1.3.0/fits.sh \
    && rm /fits/fits-1.3.0.zip

# copy gemfiles to production folder
COPY Gemfile Gemfile.lock $APP_PRODUCTION

# install gems to system - use flags dependent on RAILS_ENV
RUN cd $APP_PRODUCTION && \
    bundle config build.nokogiri --use-system-libraries \
    && if [ "$RAILS_ENV" = "production" ]; then \
            bundle install --without test:development; \
        else \
            bundle install --without production --no-deployment; \
        fi \
    && mv Gemfile.lock Gemfile.lock.built_by_docker

# copy the seeds
COPY ./seed /seed

# create a folder to store derivatives, file uploads and cache directory
RUN mkdir -p $DERIVATIVES_PATH
RUN mkdir -p $UPLOADS_PATH
RUN mkdir -p $CACHE_PATH

# copy the application
COPY . $APP_PRODUCTION
COPY docker-entrypoint.sh /bin/

# use the just built Gemfile.lock, not the one copied into the container and verify the gems are correctly installed
RUN cd $APP_PRODUCTION \
    && mv Gemfile.lock.built_by_docker Gemfile.lock \
    && bundle check

# generate production assets if production environment
RUN if [ "$RAILS_ENV" = "production" ]; then \
        cd $APP_PRODUCTION \
        && SECRET_KEY_BASE_PRODUCTION=0 bundle exec rake assets:clean assets:precompile; \
    fi

WORKDIR $APP_WORKDIR

RUN chmod +x /bin/docker-entrypoint.sh
