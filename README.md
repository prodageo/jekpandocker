# jekpandocker
All stuff (Dockerfile, ...) to generate Docker image for jekyll+pandoc+rspec

## Usage

### Prerequisites
- Suppose your desktop is Windows 10 (Powershell), [Git installed](https://gitforwindows.org/), Docker installed and running (as administrator).
- Have a Jekyll site in C:\tmp\minimal

### Commands
> 0A> open a Windows Powershell command (as administrator)

> 0B> cd /tmp

> 1A> git clone git clone https://github.com/prodageo/jekpandocker

> 2A> (Get-Content 'copy/all/usr/jekyll/bin/bundle' -Raw) -match "\n$"

> 3A> cd /tmp/jekpandocker

> 4A> docker build -t jekpandocker-image .

> 5A> docker run --rm --name jekpandocker-container -v "C:\tmp\minimal\:/srv/jekyll/" jekpandocker-image

### Notes about some commands
#### 2A
This [command](https://stackoverflow.com/a/54335814/12824964) checks the line endings of files that will be read in the container. If returns false, probably the line endings of files have been set to crlf (\r\n) by git clone, check the [git attribute value of core.autocrlf](https://stackoverflow.com/a/20653073/12824964).
Credits from Stackoverflow pseudo: [Charles Ross](https://stackoverflow.com/users/1337544/charles-ross), [Antony Hatchkins](https://stackoverflow.com/users/237105/antony-hatchkins)

# Credits
All this stuff would not have been possible without great work done in:
- https://github.com/envygeeks/jekyll-docker/blob/master/opts.yml
- https://github.com/p3palazzo/jekyll-pandoc-docker

