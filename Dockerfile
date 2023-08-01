ARG pandoc_version=3.1.1
ARG jekyll_version=4.2.2

# FROM pandoc/core:${pandoc_version} AS pandoc-base
FROM pandoc/latex AS pandoc-base

LABEL maintainer "Frederic BAUCHER <fred@baucher.net>"
COPY copy/all /


#
# EnvVars

# https://vsupalov.com/docker-arg-env-variable-guide/
# RSPEC, CAPYBARA
ENV RSPEC_OS=ALPINE
ENV RSPEC_URL=http://localhost:4000


# Ruby
#

ENV BUNDLE_HOME=/usr/local/bundle
ENV BUNDLE_APP_CONFIG=/usr/local/bundle
ENV BUNDLE_DISABLE_PLATFORM_WARNINGS=true
ENV BUNDLE_BIN=/usr/local/bundle/bin
ENV GEM_BIN=/usr/gem/bin
ENV GEM_HOME=/usr/gem
ENV RUBYOPT=-W0

#
# EnvVars
# Image
#

ENV JEKYLL_VAR_DIR=/var/jekyll
# ENV JEKYLL_DOCKER_TAG=<%= @meta.tag %>
# ENV JEKYLL_VERSION=<%= @meta.release?? @meta.release : @meta.tag %>
# ENV JEKYLL_DOCKER_COMMIT=<%= `git rev-parse --verify HEAD`.strip %>
# ENV JEKYLL_DOCKER_NAME=<%= @meta.name %>
ENV JEKYLL_DATA_DIR=/srv/jekyll
ENV JEKYLL_BIN=/usr/jekyll/bin
ENV JEKYLL_ENV=development

#
# EnvVars
# System
#

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV TZ=America/Chicago
ENV PATH="$JEKYLL_BIN:$PATH"
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US

#
# EnvVars
# User
#

# <% if @meta.env? %>
#  ENV <%= @meta.env %>
# <% end %>

#
# EnvVars
# Main
#

env VERBOSE=false
env FORCE_POLLING=false
env DRAFTS=false



RUN apk update \
	&& apk --no-cache add \
	cabal \
	ghc-dev \
	libffi-dev \
	musl-dev \
	wget

RUN cabal update && cabal install \
	pandoc-sidenote

FROM jekyll/jekyll:${jekyll_version}

# first dirs: dirs on the pandoc-base build image
# last dir: destination dir on the run image

# copy pandoc stuff
COPY --from=pandoc-base \
	/usr/local/bin/pandoc \
	/usr/local/bin/pandoc-crossref \
	/root/.cabal/bin/pandoc-sidenote \
	/usr/local/bin/
	
# rsvg-convert (used to convert images in pandoc markdown source file). Available in librsvg.
# for info, under windows can be added with: choco install rsvg-convert
RUN apk --no-cache add \
	librsvg
	# curl \
	# graphviz \
	# plantuml

	

####################################### PDF Latex - BEGIN ###################################### 	
# copy texlive stuff
COPY --from=pandoc-base \
	/opt/ \	
	/opt/

ENV TEXLIVE_BIN=/opt/texlive/texdir/bin/default
ENV PATH="$TEXLIVE_BIN:$PATH"
####################################### PDF Latex - END ###################################### 	


####################################### PLANTUML - BEGIN ###################################### 
# Install Additional Tools for System, Pandoc, and Latex
# RUN apt-get update && apt-get -y install \
#    curl graphviz librsvg plantuml
####################################### PLANTUML - END ###################################### 


####################################### TUFTE in PDF - BEGIN ###################################### 
# add the missing packages ! (latex hell)

# pandoc/latex contains biditufte*.cls but not tufte-latex.cls
# https://github.com/rstudio/rmarkdown/issues/249: maybe this one are missing like in fedora (sudo yum install texlive-tufte-latex texlive-titlesec texlive-units texlive-lipsum)
# https://github.com/dc-uba/docker-alpine-texlive: add package in an Alpine image
# Install additional packages

# https://tufte-latex.github.io/tufte-latex/  : list of necessary packages
## changepage fancyhdr fontenc geometry hyperref  natbib bibentry optparams paralist placeins ragged2e setspace textcase textcomp titlesec titletoc xcolor xifthen
## optional: beramono helvet mathpazo soul microtype
### Note microtype package contains letterspace

RUN apk --no-cache add perl wget
# tlmgr install <NEW_PACKAGES> bytefield algorithms algorithm2e ec fontawesome && \
# RUN tlmgr install tufte-latex hardwrap
# RUN tlmgr install changepage fancyhdr fontenc geometry hyperref  natbib bibentry optparams paralist placeins ragged2e setspace textcase textcomp titlesec titletoc xcolor xifthen
# RUN tlmgr install units morefloats
# RUN tlmgr install beramono helvet mathpazo soul microtype

# ERROR ! I can't find file `pplr9d'.
# CORRECTION
# RUN tlmgr install  palatino mathpazo fpl
	
# remove useless commands when running Docker (if you are confident that all package have been identified)
# RUN apk del perl wget

# Comment for people not fluent in pandoc and latex stuff
# https://yihui.org/tinytex/#maintenance
# find the package containing the missing styles (*.sty)
# - tlmgr search --global --file "/times.sty" => psnfss
# - tlmgr install psnfss
####################################### TUFTE in PDF - END ###################################### 	
	
RUN apk --no-cache add \
	gmp \
	libffi \
	lua5.4 \
	lua5.4-lpeg
#
# Gems
# Update
#

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc
RUN unset GEM_HOME && unset GEM_BIN && \
  yes | gem update --system

#
# Gems
# Main
#

RUN unset GEM_HOME && unset GEM_BIN && yes | gem install --force bundler
# RUN gem install jekyll -v<%= @meta.release??   @meta.release : @meta.tag %> --     --use-system-libraries
RUN gem install jekyll

#
# Gems
# User
#

# <% if @meta.gems? %>
#   # Stops slow Nokogiri!
#  RUN gem install <%=@meta.gems %> -- \
#    --use-system-libraries
# <% end %>


# commented at 2023-07-27 - 15h56
## RUN addgroup -Sg 1000 jekyll
## RUN adduser  -Su 1000 -G jekyll jekyll

#
# Remove development packages on minimal.
# And on pages.  Gems are unsupported.
#

# <% if @meta.name == "minimal" || @meta.name == "pages" || @meta.tag == "pages" %>
  RUN apk --no-cache del \
    linux-headers \
    openjdk8-jre \
    zlib-dev \
    build-base \
    libxml2-dev \
    libxslt-dev \
    readline-dev \
    imagemagick-dev\
    libffi-dev \
    ruby-dev \
    yaml-dev \
    zlib-dev \
    libffi-dev \
    vips-dev \
    vips-tools \
    cmake
# <% end %>

# stuff for testing : rspec, capybara
# https://stackoverflow.com/a/55327609 => chromium-chromedriver
# https://stackoverflow.com/questions/72663421/fail-to-install-install-racc-v-1-6-0#comment128898351_72663421 => build-base
RUN apk --no-cache add \
	chromium-chromedriver \ 
	build-base 

RUN mkdir -p $JEKYLL_VAR_DIR
RUN mkdir -p $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_DATA_DIR
RUN chown -R jekyll:jekyll $JEKYLL_VAR_DIR
RUN chown -R jekyll:jekyll $BUNDLE_HOME
RUN rm -rf /home/jekyll/.gem
RUN rm -rf $BUNDLE_HOME/cache
RUN rm -rf $GEM_HOME/cache
RUN rm -rf /root/.gem

# Work around rubygems/rubygems#3572
RUN mkdir -p /usr/gem/cache/bundle
RUN chown -R jekyll:jekyll \
  /usr/gem/cache/bundle

CMD ["jekyll", "--help"]
ENTRYPOINT ["/usr/jekyll/bin/entrypoint"]
WORKDIR /srv/jekyll
VOLUME  /srv/jekyll
EXPOSE 35729
EXPOSE 4000
