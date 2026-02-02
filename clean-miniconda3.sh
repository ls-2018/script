
sudo rm -rf /opt/miniconda3
code ~/.bash_profile
code ~/.zshrc
rm -rf ~/.anaconda*
rm -rf ~/.conda*
rm -rf ~/.condarc*

# conda install anaconda-clean --yes
anaconda-clean --yes  # 自动删除备份文件和历史记录

# conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
# conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/main/
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/pkgs/free/
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/conda-forge/
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/msys2/
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/bioconda/
# conda config --add channels https://mirrors.ustc.edu.cn/anaconda/cloud/menpo/
 
# conda config --set show_channel_urls yes 
# conda config --set auto_activate_base false
 