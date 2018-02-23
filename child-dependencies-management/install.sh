#! /bin/sh

helm create parent
helm create dep1
helm create dep2

## DEP1
touch dep1/requirements.yaml
cat >  dep1/requirements.yaml << EOM
dependencies:
- name: dep2
  version: 0.1.0
  repository: "file://../dep2"
  condition: dep2.enabled
EOM


cat >>  dep1/values.yaml << EOM

dep2:
  enabled: true
EOM
helm dependency update dep1


## PARENT
touch parent/requirements.yaml
cat >  parent/requirements.yaml << EOM
dependencies:
- name: dep1
  version: 0.1.0
  repository: "file://../dep1"
  condition: dep1.enabled
EOM

# Define 1 file with dep2 enabled and other with dep2 disabled for parent
cat >>  parent/values.yaml << EOM

dep1:
  enabled: true
EOM
cp parent/values.yaml parent/values_fail_nodep2.yaml
cat >>  parent/values_nodep2.yaml << EOM
  dep2:
    enabled: false
EOM
helm dependency update parent

mv parent/values.yaml parent/values_ok_nodep2.yaml
cat >>  parent/values_nodep2.yaml << EOM

dep2:
  enabled: false
EOM
helm dependency update parent



