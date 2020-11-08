---
title: Cheatsheet
description: Some common opam commands all in one place 
date: 2020-10-05 11:00:44
---

```
# Check for well formatted opam files 
$ opam lint 

# Install a package 
$ opam install yaml

# Update repository and upgrade the packages 
$ opam update && opam upgrade 

# List packages which are installed in your current switch
$ opam list --installed 

# List packages which depend on a certain other package 
$ opam list --depends-on yaml

# Pretty print the meta information for a package, add --raw for the file 
$ opam show irmin

# Pin a package not using git, but just the actual file content 
$ opam pin add . --kind=path 

# Create a new global switch with compiler 4.11.0 
$ opam switch create 4.11.0

# Create a new local switch with compileer 4.11.0
$ opam switch create . 4.11.0

# List all of my switches and indicate which I am currently on
$ opam switch

# Clean the cache 
$ opam clean
```