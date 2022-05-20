To make contribution to this repository please follow the following steps:
1) Ensure you have the most recent version of master and have [set-up pre-commit hooks](https://github.nrel.gov/reV/reV2/wiki/Setting-up-Pre-commit-Hooks)
2) Create a feature branch off of master
    * `git checkout -b new_feature_branch`
3) Make commits to your feature branch
4) Once your feature is complete, rebase with master if necessary (to incorporate any changes made to master during your feature development)
    * `git fetch --all`
    * `git rebase origin/master`
    * `git push origin --force` **Make sure to force push after rebasing (see [Git Best Practices](https://github.nrel.gov/reV/reV2/wiki/Git-Best-Practices) for more details)**
5) Submit a pull request and specify a reviewer
6) Integrate any necessary changes identified during code review
7) Once feature is complete and ready to be merged, update docs
    * Delete the contents of `source/reV`
    * Run `sphinx-apidoc -o source/reV ..` from the `docs` folder
    * `git commit` and `git push` changes to the documentation source code as needed
8) Merge feature branch into master branch and delete feature branch
    * Merge pull request using the Github pull request web interface
    * `git branch -d your_feature_branch`

Thanks for contributing!
