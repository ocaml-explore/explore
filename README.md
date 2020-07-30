Explore OCaml 
-------------

🚧 WIP: Under Construction 🚧

Explore OCaml is a centralised source for workflows in OCaml categorised by user, tools and libraries with rich linking to external sources of information. It aims to provide all users with the recommended way to be productive in getting something done in OCaml. This could be:

 - Getting started with learning the language
 - Adding CI and unit tests to your OCaml library 
 - Generating and deploying documentation for your project
 - Installing a tool built in OCaml

## Building Locally

If you want to run the code locally you will need to clone this repository, install the dependencies and finally install `explore` - from here you can run `explore build` from the root and copy the static folder into the content folder (`cp -r ./static/* ./content`). Next run a [http server](https://developer.mozilla.org/en-US/docs/Learn/Common_questions/set_up_a_local_testing_server#Running_a_simple_local_HTTP_server) from the content folder. 

It is a good idea to leave the server running in one terminal and edit, run `explore build` and copying css from another terminal to see your changes. 