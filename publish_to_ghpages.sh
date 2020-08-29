
#!/bin/sh

if [ "`git status -s`" ]
then
    echo "The working directory is dirty. Please commit any pending changes."
    git add --all && git commit -m "update content"
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public upstream/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo

echo "Add cname File"
echo "blog.gangjun.dev" >> public/CNAME


echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Publishing to gh-pages (publish.sh)"

if (whiptail --title "Blog Deploy" --yesno "Do you want to push on github?" 10 60) then
    echo "You chose Yes. Exit status was $?."
    echo "Pushing to github"
    git push origin master
    git push upstream gh-pages -f
fi

