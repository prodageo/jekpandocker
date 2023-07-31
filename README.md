# jekpandocker
Dockerfile to generate a **Docker** image for helping in [single source publishing](https://en.wikipedia.org/wiki/Single-source_publishing), with all sources of documentation written in [_pandoc markdown_](https://pandoc.org/MANUAL.html#pandocs-markdown) and a publication workflow based on **Jekyll**, with **pandoc** as the Markdown rendering engine and theme based on Tufte. Output expected in HTML (Jekyll) and PDF.

## Usage
How to run your Jekyll site in the container provided by _fbab/jekpandocker_ ?

### Prerequisites
- Suppose your desktop is Windows 10 (Powershell), [Git installed](https://gitforwindows.org/), Docker installed and running (as administrator).
- Have a Jekyll site in C:\tmp\minimal

### Use on desktop the remote predefined image
You can visit the image page on [DockerHub](https://hub.docker.com/r/fbab/jekpandocker).
> docker pull fbab/jekpandocker

> docker run --rm --name jekpandocker-container -v "C:\tmp\minimal\:/srv/jekyll/" fbab/jekpandocker jekyll serve

### Load in CI/CD the remote predefined image
The same image can be reffered in CI/CD scripts

#### Github Actions
cf https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action

#### Gitlab 
Example of .gitlab-ci.yml
```gitlab
image: fbab/jekpandocker
  script:
    - gem install bundler
    - bundle install
    - bundle exec jekyll build -d public --trace --config _config.yml,_config_gitlab.yml
    - pwd
    - find . -name "*"
  artifacts:
    paths:
      # The folder that contains the files to be exposed at the Page URL ...
      - public
  rules:
    # This ensures that only pushes to the default branch will trigger
    # a pages deploy // $CI_COMMIT_REF_NAME
    - if: $CI_COMMIT_REF_NAME == $CI_DEFAULT_BRANCH
```
### Build on your own
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

