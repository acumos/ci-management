---
- project:
    name: acumos-hippo-cms-project
    project-name: acumos-hippo-cms
    project: acumos-hippo-cms
    mvn-settings: acumos-hippo-cms-settings
    jobs:
      - '{project-name}-maven-jobs'
      # merge job is not yet part of global JJB
      - gerrit-maven-merge
      # TODO: ADD DOCKER
    stream:
      - master:
          branch: master
