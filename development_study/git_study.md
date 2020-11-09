## git study

1.Git 保存用户名和密码

	git config credential.helper store
	
	参考
	$ man git | grep -C 5 password
	$ man git-credential-store
	
	这样保存的密码是明文的，保存在用户目录~的.git-credentials文件中
	$ file ~/.git-credentials
	$ cat ~/.git-credentials


EXAMPLES

The point of this helper is to reduce the number of times you must type your username or password. For example:

	$ git config credential.helper store
	$ git push http://example.com/repo.git
	Username: <type your username>
	Password: <type your password>

	[several days later]
	$ git push http://example.com/repo.git
	[your credentials are used automatically]


### git branch
```
Deleting local branches in Git
git branch -d feature/login
git branch -D branch branch2 --force

Deleting remote branches in Git
git branch -dr origin/feature/login

To delete a remote branch you need to push the delete:
git push remote --delete branch

The –delete option is newish, so if your git is old you can use the original syntax:
git push remote :branch


To delete a local branch
git branch -d the_local_branch

To remove a remote branch (if you know what you are doing!)
git push origin :the_remote_branch


If you get the error error: unable to push to unqualified destination: the_remote_branch The destination refspec neither matches an existing ref on the remote nor begins with refs/, and we are unable to guess a prefix based on the source ref. error: failed to push some refs to 'git@repository_name'

perhaps someone else has already deleted the branch. Try to synchronize your branch list with
git fetch -p 


```

#### github clone push 提速

>其实git clone或者git push特别慢，并不是因为http://github.com的这个域名被限制了。而是"http://github.global.ssl.fastly.Net"这个域名被限制了。那么首先查到这个域名的ip。然后再hosts文件中进行ip->域名映射就可以了。这个办法会让clone或者push速度飞起。

#### fatal: refusing to merge unrelated histories
因为他们是两个不同的项目，要把两个不同的项目合并，git需要添加一句代码，在git pull，这句代码是在git 2.9.2版本发生的，最新的版本需要添加--allow-unrelated-histories

#### git rm -r --cached 去掉已经托管在git上的文件
但是有时候，gitignore考虑不全面，发现有不该提交的文件已经提交后，仅仅在.gitignore中加入忽略是不行的。这个时候需要执行:

git rm -r --cached filename 
去掉已经托管的文件，然后提交即可

#### 删除远程分支
如果不再需要某个远程分支了，比如搞定了某个特性并把它合并进了远程的 master 分支（或任何其他存放稳定代码的分支），可以用这个非常无厘头的语法来删除它：git push [远程名] :[分支名]。如果想在服务器上删除 serverfix 分支，运行下面的命令：

```
$ git push origin :serverfix
To git@github.com:schacon/simplegit.git
 - [deleted]         serverfix
```
#### 解决git 出现 Your account has been blocked问题

```
git remote set-url origin http://git.corp.doumi.com/algorithm/algo_poppy.git
``


```
//全局设置
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

//本地项目设置
git config user.email "you@example.com"
git config user.name "Your Name"
```

### git回退到某个历史版本
```
git log -3
git reset --hard 139dcfaa558e3276b30b6b2e5cbbb9c00bbdca96 
```