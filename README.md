# jekpandocker
All stuff (Dockerfile, ...) to generate Docker image for jekyll+pandoc+rspec

## Usage
Suppose you have a Jekyll site in C:\tmp\minimal

### Commands
> 0A> cd /tmp

> 1A> git clone git clone https://github.com/prodageo/jekpandocker

2A> (Get-Content 'bundle' -Raw) -match "\n$"

3A> cd /tmp/jekpandocker

4A> docker build -t jekpandocker-image .

5A> docker run --rm --name jekpandocker-container -v "C:\tmp\minimal\:/srv/jekyll/" jekpandocker-image

### Notes about some commands
#### 2A
This [command](https://stackoverflow.com/a/54335814/12824964) checks the line endings of files that will be read in the container. If returns false, check the [git attribute value of core.autocrlf](https://stackoverflow.com/a/20653073/12824964).
Credits : [Charles Ross](https://stackoverflow.com/users/1337544/charles-ross), [Antony Hatchkins](https://stackoverflow.com/users/237105/antony-hatchkins)

# Credits
All this stuff would not have been possible without great work done in:
- https://github.com/envygeeks/jekyll-docker/blob/master/opts.yml
- https://github.com/p3palazzo/jekyll-pandoc-docker

