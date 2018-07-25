FROM ubuntu:18.04

ARG USER_NAME="uhoi"

# RUNはキャッシュされるのでupdateとinstallは同じ行に記載する。
# そうすることでinstallを増やしてもupdateが行われる。
RUN set -x && \ 
    apt-get update && apt-get install -y \
    nodejs npm \
    vim git sudo wget curl zip screen && \
    npm cache clean && \
    npm install n -g && \
    n v8.10 && \
    ln -sf /usr/local/bin/node /usr/bin/node && \
    apt-get purge -y nodejs npm

# Create an user. ヒント:そんなんでいいんですか？
RUN useradd -p '$6$LScWzUdCoiBRNs$Gy2r/B5o.HhhF8v5KvRhdGSdcBR7xKoirRCMt/l1R6UxpIfvYzdYrBf3S8CubVIO7ul16UcjOqPainka94dTe1' \
    -d /home/${USER_NAME} -m -s /bin/bash ${USER_NAME} 
RUN usermod -G sudo ${USER_NAME}

# workdir
WORKDIR /home/${USER_NAME}

# vimの設定
ADD vim /home/${USER_NAME}/.vim
RUN ln -s /home/${USER_NAME}/.vim/vimrc.vim /home/${USER_NAME}/.vimrc
# Neobundle準備
RUN mkdir -p /home/${USER_NAME}/.vim/bundle
RUN git clone git://github.com/Shougo/neobundle.vim /home/${USER_NAME}/.vim/bundle/neobundle.vim
# Eslint
RUN npm install -g eslint eslint-config-airbnb eslint-plugin-react eslint-plugin-import
ADD vim/eslintrc /home/${USER_NAME}/.eslintrc
# 権限設定
RUN chown ${USER_NAME}:${USER_NAME} -R /home/${USER_NAME}/.vim

# AWS CLI
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
    python get-pip.py && \
    pip install awscli

USER ${USER_NAME}
EXPOSE 8100

