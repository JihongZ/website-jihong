---
title: "Updating R Version Without missing packages"
author: 
- "Jihong Zhang"
date: 2018-04-29
categories:
- blog
tags:
- R
- Education
- proposal
---

After updating to new R version (4.5) from old version, you have to re-install all packages by default. However, there're some solution for that.

## Unix (MacOs, Linux)

  1.Create a new folder in home directory to store the packages. Sometimes, you need to change the permission level for this folder, or R may not have access to write this folder. **Rlibs** is a special folder where you can store all you packages.

```bash
sudo mkdir ~/Rlibs
```

  2.Edit the **.Reviron** file in your home directory ("~") (create a new file if you don't have it). Add the code below to let R know where is the installed Packages. R will read the configuration in the background from the path "~/.Reviron".

   ```
   R_LIBS=~/Rlibs
   ```

 3.Re-install you packages. After that you shall see your packages are stored in Rlibs folder.