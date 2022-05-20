This is a guide of git best-practices that should be followed while doing development on the reV 2.0 repository. The reV 2.0 development team practices [github flow](https://guides.github.com/introduction/flow/). For more git resources see [this git tutorial](https://github.nrel.gov/DAWG/git-tutorial), courtesy of Dheepak Krishnamurthy.

Best-Practices:

1. Use the [Github insights network](https://github.nrel.gov/reV/reV2/network) to understand the branch workflow.

2. Always branch off of Master (from the master branch: `git checkout -b new_branch_name`)

3. Rebase master before performing pull request (from your dev branch: `git rebase master`)

    a. You will need to perform a `git push origin --force` after this, here's why: the rebase plays your branch's commits on top of the latest master commit. This will likely result in your branch having new commit checksums. Performing a `git push origin --force` after rebasing master will reset the origin with the correct rebase and new checksums.

4. Perform pull requests frequently

    a. Aim for a 2 week branch lifetime

5. Always push commits

    a. Prevents risk of work loss due to laptop loss

    b. Creates risk of other people using commits that you later squash, but 7B but will prevent this

6. Try and avoid work planning that has branch-to-branch dependencies, but if branch-to-branch is required:

    a. Use `git merge` to utilize commits/features from other branches

    b. Use 7B to remove these commits/features before submitting a pull request to avoid duplicate commits and ensuing conflicts

    c. Be very cautious with cherry pick and use git rere if you do (`git config --global rerere.enabled true`)

7. Use interactive rebase for:

    a. Squashing and re-organizing commits

    b. Removing (dropping) commits from other feature branches (see 6B) before doing a pull request

    c. Command line example (from your dev branch): `git rebase -i origin/master`

8. Sometimes you will find that your local branch (or even your local master branch) gets corrupted. You can reset your local branch to the origin instance by performing the following:

    a. `git fetch --all`

    b. `git reset --hard origin/your_branch_name`
