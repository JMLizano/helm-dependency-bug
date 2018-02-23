# helm-dependency-bug

There are two problems with helm dependency management:

1. Child dependencies management

The problem encountered here is related to how helm manage parameter value passing to childs.


Suppose we have a chart 'parent' that depends on a chart 'dep1' and this one depends on 'dep2'. The requirements files would look something like this:

PARENT
```yaml
dependencies:
- name: dep1
  version: 0.1.0
  repository: "file://../dep1"
  condition: dep1.enabled
```

DEP1
```yaml
dependencies:
- name: dep2
  version: 0.1.0
  repository: "file://../dep2"
  condition: dep2.enabled
```

In a normal scenario where we install parent chart, helm will also install dep1 and dep2 charts. But if we do not want to install dep2 (ej. already installed), we should set dep2.enabled to false, and here is where the problem laids.

The intuitive thing to do would be to write some values file for the parent like this:

```yaml
(...)
dep1:
  enabled: true
  dep2:
    enabled: false
```

since dep2 is part of the values file of dep1. But this will not work, dep2 needs to be a root level declared variable like this:

```yaml
(...)
dep1:
  enabled: true
dep2:
  enabled: false
```

this may cause some problems when working with circular dependencies (Ej. Schema-registry chart is a dependency for Kafka chart and it itself has kafka as a dependency), since this
could cause some variable name collision.

2. Dependency collision 

An extender explanation of this problem (and a possible solution) can be seen [here](https://github.com/kubernetes/helm/issues/2762)

