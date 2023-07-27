# jekpandocker
All stuff (Dockerfile, ...) to generate Docker image for jekyll+pandoc+rspec

## Usage
Suppose you have a Jekyll site in C:\tmp\minimal

> mkdir /tmp/jekpandocker

> git clone git clone https://github.com/prodageo/jekpandocker

> cd jekpandocker

> docker build -t jekpandocker-image .

> docker run --rm --name jekpandocker-container -v "C:\tmp\minimal\:/srv/jekyll/" jekpandocker-image