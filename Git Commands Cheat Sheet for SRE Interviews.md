# 📌 Git Commands Cheat Sheet for SRE Interviews

## **🔹 Overview of Git for SREs**
Git is an essential tool for **Site Reliability Engineers (SREs)** to manage code repositories, collaborate efficiently, and maintain infrastructure as code (IaC). This cheat sheet covers **critical Git commands** used in troubleshooting, branching strategies, and automation.

---

## **🔹 Git Workflow Diagram**

```plaintext
  (Working Directory)       (Staging Area)         (Repository)
        ↓                         ↓                     ↓
  Modify Files            git add <file>         git commit -m "msg"   
        ↓                         ↓                     ↓
  Untracked/Modified   Changes Staged       Save to Local Repo
        ↓
    git push origin <branch>   →  Upload to Remote Repo
```

---

## **1️⃣ Git Configuration & Setup**
| **Command** | **Description** |
|------------|----------------|
| `git config --global user.name "Your Name"` | Set your Git username. |
| `git config --global user.email "your@email.com"` | Set your Git email. |
| `git config --global core.editor "vim"` | Set default text editor. |
| `git config --list` | Show current Git config. |

---

## **2️⃣ Repository Management**
| **Command** | **Description** |
|------------|----------------|
| `git init` | Initialize a new Git repository. |
| `git clone <repo_url>` | Clone a repository from a remote source. |
| `git remote -v` | List remote repositories. |
| `git remote add origin <repo_url>` | Add a new remote repository. |
| `git remote set-url origin <new_url>` | Change the URL of the remote repository. |

---

## **3️⃣ Git Branching & Merging**
| **Command** | **Description** |
|------------|----------------|
| `git branch` | List all branches. |
| `git branch <branch_name>` | Create a new branch. |
| `git checkout <branch_name>` | Switch to a specific branch. |
| `git checkout -b <new_branch>` | Create and switch to a new branch. |
| `git merge <branch_name>` | Merge a branch into the current branch. |
| `git rebase <branch_name>` | Reapply commits on top of another base branch. |

---

## **4️⃣ Staging, Committing & Logs**
| **Command** | **Description** |
|------------|----------------|
| `git status` | Show modified files in working directory. |
| `git add <file>` | Add a file to the staging area. |
| `git add .` | Stage all modified files. |
| `git commit -m "message"` | Commit changes with a message. |
| `git commit --amend -m "new message"` | Modify the last commit message. |
| `git log --oneline --graph --decorate --all` | Display commit history graphically. |
| `git reflog` | Show history of HEAD changes (useful for recovery). |

---

## **5️⃣ Undoing Changes**
| **Command** | **Description** |
|------------|----------------|
| `git checkout -- <file>` | Discard changes in the working directory. |
| `git reset HEAD <file>` | Unstage a file from the staging area. |
| `git reset --soft HEAD~1` | Undo last commit but keep changes staged. |
| `git reset --hard HEAD~1` | Completely remove the last commit. |
| `git revert <commit_hash>` | Create a new commit that undoes a previous commit. |
| `git cherry-pick <commit_hash>` | Apply a specific commit from another branch. |

---

## **6️⃣ Synchronizing with Remote Repository**
| **Command** | **Description** |
|------------|----------------|
| `git pull origin <branch>` | Fetch latest changes and merge from remote. |
| `git fetch --all` | Fetch all branches without merging. |
| `git push origin <branch>` | Push local changes to remote repository. |
| `git push -u origin <branch>` | Push branch and track it with upstream. |
| `git push --force` | Force push (⚠️ Use with caution). |

---

## **7️⃣ Git Tags (Version Control)**
| **Command** | **Description** |
|------------|----------------|
| `git tag` | List all tags. |
| `git tag -a v1.0 -m "Release version 1.0"` | Create an annotated tag. |
| `git push origin --tags` | Push tags to remote repository. |
| `git tag -d v1.0` | Delete a tag locally. |
| `git push origin :refs/tags/v1.0` | Delete a remote tag. |

---

## **8️⃣ Git Bisect (Finding Bugs)**
| **Command** | **Description** |
|------------|----------------|
| `git bisect start` | Start bisecting to find a bad commit. |
| `git bisect bad` | Mark current commit as bad. |
| `git bisect good <commit_hash>` | Mark commit as good and find where bug was introduced. |
| `git bisect reset` | Exit bisect mode. |

---

## **9️⃣ Git Stash (Temporary Work)**
| **Command** | **Description** |
|------------|----------------|
| `git stash` | Save uncommitted changes temporarily. |
| `git stash list` | Show list of stashes. |
| `git stash apply` | Apply last stash. |
| `git stash drop` | Delete the last stash. |
| `git stash pop` | Apply the stash and remove it from the stash list. |

---

## **🔹 Best Practices for SRE Engineers**
✅ **Always pull before pushing** (`git pull origin main`) to prevent conflicts.
✅ **Use descriptive commit messages** to maintain clarity in collaboration.
✅ **Leverage branches** for feature development and bug fixes.
✅ **Use Git hooks** (`pre-commit`, `post-merge`) to enforce coding standards.
✅ **Keep repositories clean** by deleting unused branches (`git branch -d <branch>`).

---

## **🚀 Summary of Key Git Commands for SREs**
| **Category** | **Key Commands** |
|-------------|----------------|
| **Setup** | `git config --global`, `git init`, `git clone` |
| **Branching** | `git branch`, `git checkout`, `git merge`, `git rebase` |
| **Commit & Logs** | `git add`, `git commit`, `git log`, `git reflog` |
| **Undo Changes** | `git checkout`, `git reset`, `git revert`, `git cherry-pick` |
| **Sync with Remote** | `git pull`, `git fetch`, `git push`, `git push --force` |
| **Tags & Releases** | `git tag`, `git push --tags`, `git tag -d` |
| **Bug Tracking** | `git bisect`, `git stash`, `git stash pop` |

✅ **Mastering these commands ensures smooth Git workflow management for SRE engineers!** 🚀