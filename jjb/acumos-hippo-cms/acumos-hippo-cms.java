---
- project:
    name: acumos-hippo-cms-project
    # jenkins job name prefix
    project-name: acumos-hippo-cms
    # git repo
    project: acumos-hippo-cms
    mvn-settings: acumos-hippo-cms-settings
    # pass Jenkins build number
    mvn-params: -Dbuild.number=${{BUILD_NUMBER}}
    # needs docker-enabled build node
    build-node: centos7-docker-4c-4g
    jobs:
      - gerrit-maven-dl-verify
      - gerrit-maven-dl-merge
      - gerrit-maven-dl-release
      # javadoc group has -publish and -verify
      - '{project-name}-maven-javadoc-jobs'
      - gerrit-maven-sonar
    stream:
      - master:
          branch: master
