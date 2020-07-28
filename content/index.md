---
title: "Start Exploring OCaml"
date: 2020-07-27 09:35:49
---

One of the biggest problems programming languages face in a real world setting is that getting started with them isn't necessarily easy. OCaml is no exception. There tend to be lots of great resources explaining interesting aspects of the language like GADTs or the module system - but not as many centred around productivity workflows i.e. getting things done in OCaml. 

Often these workflows are obvious... once you know them. Explore OCaml is a centralised source for workflows in OCaml categorised by user, tools and libraries with rich linking to external sources of information.

Here are some of the common problems users face: 

1. I'm running the `ABC` operating system, how do I get started with OCaml? (In particular the Windows experience).
2. I want to build a library that does `X`, what is the best workflow* for achieving this?
3. I just want to run some *Hello-World* examples and get started with OCaml - how do I do this? (similar to 1)
4. I've noticed a bug in library `Y` - how do I fix it and contribute to the original library?
5. OCaml seems to have many backends - *x86, ARM, RISC-V, JavaScript* - but how do I use them?
6. There is a cool tool written in OCaml - how do I install and use it? 
7. I'm running on OS `ABC` but want to compile for `XYZ` - can I do that in OCaml?

**workflow: this involves testing, publishing, formatting, building etc. all of the common tooling that needs to be in place to allow most programming languages to solve real world problems.*

This site aims to answer these questions for you, as well as let you discover more advanced workflows as your use of OCaml grows. First, we'll introduce the only essential tool you need — opam.

# Opam

------------- 

[Opam](https://opam.ocaml.org/) is the the OCaml package manager.  In order to join the OCaml open source community, all you need to do is to add an [opam file](./pages/opam-files) to your project.  This `opam` file describes the build instructions for your project, as well as any dependencies it might need. An `opam` file is useful for a project of any size — from toy learning exercises to big theorem provers — since it allows someone else to easily rebuild and replicate your work, and even extend it if they choose to.

Once you are comfortable with your code and want to share it more publicly, an opam file can be published to the central OCaml [opam repository](https://github.com/ocaml/opam-repository/).  This is a collection of tens of thousands of packages that have been contributed freely by the community since 2013.  The opam-repository does not contain the full source code to your project; instead, it tracks pointers to different versions of your code, and also the various compatibility constraints to automatically figure out which versions work with each other.  The usual mechanism to track your releases is to use a version control system such as git.  You can [browse the packages](https://opam.ocaml.org) online to see what's available.

How do you actually manipulate opam files?  There are several tools that can parse these files and repositories and install the software you want.  The primary reference implementation that runs on macOS and Linux is also the [opam client](./pages/opam-client) , and is the first thing you will want to configure on your system to get started.  Read on below for more details about opam files and the client.  If you'd like to just get on with a particular task, skip to the next section to find out which archetype you best fit into.

[opam files](./pages/opam-files)

[opam client](./pages/opam-client)

# Workflows

--------------- 

Below are three lists: archetypical users, meet the tools and community libraries. All workflows have one or more users in mind with most using a tool from the OCaml Platform. The community libraries are popular projects which have become standard for certain workflows. 

To get started with workflows, open the user that best describes you and start exploring! 

## Learning the Language 📚

**Beginner:** If you are just getting started on learning the OCaml language, there are several resources to get you going.  The [beginner](./users/beginner) workflows will get you familiar with where you can find answers to common questions, find interactive playgrounds, and hook into possibly familiar learning mechanisms such as Jupyter notebooks.

**Teachers:** If you are teaching OCaml to a class, then you will need to support the installation of the tools on a variety of platforms, and hook into grading systems.  The [teaching](./users/teacher) workflows will cover that, and also link to projects that exist to support your efforts.

## Developing in OCaml 🧠

**Application Developer:** If you have found an OCaml application that you want to work on and extend, then read on about the [Application Developer](./users/application-developer) workflows.  This will get you started with a build environment and all the dependencies you need to build the application within a modern IDE.

**Library Author:** If you want to break up your application into reusable chunks, then you will create OCaml libraries.  As a [Library Author](./users/library-author), you will learn how to partition your source code into multiple libraries, to write unit tests and documentation, to apply auto-formatting, and eventually publish them publicly to the central opam repository.

## Distributing OCaml code 🌏

**End User:** If you are an [End User](./users/end-user) that simply wants to install an OCaml application as fast as possible on your platform, read on about how to do that.  Beyond the standard opam client, there are also several domain-specific ones that may be more useful to you, such as the opam2nix binary distributor or the esy client that supports npm-like description files.

**Distribution Manager:** If you are maintaining OCaml on a particular operating system, you will be juggling the various quirks of OCaml applications and libraries with hundreds of other programming languages and build systems.  The [Distribution Manager](./users/distribution-manager) workflows collect tools that operate over the opam repository metadata and provide mechanisms to programmatically translate them to your own distribution.

<!-- [Archetypical Users](Explore%20OCaml%20294d4a6975e84e509cdc53dc6cb1ba3b/Archetypical%20Users%20e3ac9b12886f4eb382d8d03da27ab6ff.csv) -->

# The OCaml Platform 🔨

---------------- 

The OCaml Platform is a collection of tools that allow programmers to be productive in the OCaml language. It has been an iterative process of refinement as new tools are added and older tools are updated. Different tools accomplish different workflows and are used at different points of a project's life. You can see how the platform progress in [2017](https://www.youtube.com/watch?v=y-1Zrzdd9KM), [2018](https://www.youtube.com/watch?v=oyeKLAYPmQQ) and [2019](https://speakerdeck.com/avsm/workflows-in-the-ocaml-platform). 

There is no requirement to use all of the tools. You can mix and match different combinations to suit the needs of your project and the workflows you want to accomplish.  

[Meet the tools](./platform/)

Community libraries are recommendations for additional tools and libraries to help create your OCaml projects. Whilst not part of the platform, many of them have become common use and an understanding of how they work can help you form good decisions for your own project. 

[Community Libraries](./libraries/)

<!-- ### Getting started on:

---

Brief guides on getting started on the three most common operating systems. There are a few *gotchas* to look out for and alternative ways of doing things with explanations as to what is going on. Start with **common** for a quick review of the problem we're trying to solve. 

[Common](Explore%20OCaml%20294d4a6975e84e509cdc53dc6cb1ba3b/Common%20a4216fb9ab5342c792327110a27c802d.md)

[MacOS](Explore%20OCaml%20294d4a6975e84e509cdc53dc6cb1ba3b/MacOS%202921e6dde3ae47ccb9a53341add68961.md)

[Unix](Explore%20OCaml%20294d4a6975e84e509cdc53dc6cb1ba3b/Unix%20f49e1429fc054ade997e8b3e29cf5189.md)

[Windows](Explore%20OCaml%20294d4a6975e84e509cdc53dc6cb1ba3b/Windows%20e56df5482da84558981dfad34b6e591a.md) -->

## Notes & Misc.

---------------- 

Understanding how these tools came to be requires and understanding of how the OCaml Ecosystem has evolved. This includes tools like `ocamlbuild`, `ocamlfind` and `jbuild`. Many sources of documentation and tutorials still reference some of these out-dated tools and some of the modern platform tools directly use them. 

[OCaml Ecosystem History](./pages/ocaml-ecosystem-history)

The OCaml Platform is an idealised, one-stop-shop for all things OCaml. But it too has evolved over time and changed direction.

[OCaml Platform ](./pages/ocaml-platform)



<script>
  if (window.netlifyIdentity) {
    window.netlifyIdentity.on("init", user => {
      if (!user) {
        window.netlifyIdentity.on("login", () => {
          document.location.href = "/admin/";
        });
      }
    });
  }
</script>