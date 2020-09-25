Contribute to Explore OCaml
---------------------------

The README does a fairly thorough job at explaining the structure of Explore OCaml and the tooling you can use to ease the development process. This document is a much higher level overview of how anyone can contribute. 

The [Github issues](https://github.com/ocaml-explore/explore/issues) is a good place to start. No PR is too small! Explore OCaml aims to be as up to date as possible so if a workflow looks outdated, you notice a few typos or whatever then do make a pull request. 

The best way to do this is to: 

  1. Notice a problem you want to fix - open an issue. 
  2. Fork this repository so you will have a `<username>/explore` version. 
  3. Clone this repository to start developing locally, `git clone https://github.com/<username>/explore.git`
  4. Create a new branch, `git checkout -b <my-awesome-branch>` and start fixing the issue committing to the branch as you go (`git add . && git commit -m "message goes here"`) 
  5. Once you are happy, you can push to your forked repository `git push --set-upstream origin <my-awesome-branch>`.
  6. Go to your forked copy on Github and make a "Pull Request" to the main repository referencing the issue you are fixing and any other details.

### Common Problems 

Whilst you are working on your copy, the main repository might change as other code is merged in. There are two things you need to do. One get those new copies to your forked version and rebase your branch on the latest changes. To do this you will need to: 

  1. Set the `upstream` for your repository: `git remote add upstream https://github.com/ocaml-explore/explore` 
  2. Pull upstream changes into the main branch: `git pull upstream trunk` 
  3. Rebase your code on the new main branch... this can be tricky if there are conflicts. You want to checkout your branch (`git checkout <my-awesome-branch>`) and run `git rebase trunk`. Hopefully this just works and your commits are applied to the head of the main branch. If there are conflicts you need to manually fix the conflicts then add the files with `git add <conflict-1-file> <conflict-2-file>...` - once you have fixed all of them you can run `git rebase --continue`. Repeat this process until you finally escape the conflict-nightmare and you have successfully rebased. Git can be hard, good luck! 