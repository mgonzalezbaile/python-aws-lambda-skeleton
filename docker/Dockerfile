FROM lambci/lambda:build-python3.7

ARG AWS_ACCESS_KEY_ID
ARG AWS_ACCESS_KEY_SECRET
ENV ANSIBLE_LOCAL_TEMP=/var/task
ENV ANSIBLE_VAULT_PASSWORD_FILE=/bin/vault-env
RUN curl https://lambci.s3.amazonaws.com/fs/nodejs8.10.tgz | tar -zx -C /
RUN npm install -g serverless \
    yarn
RUN yum -y install postgresql-devel
RUN pip install ansible
COPY package.json /tmp
COPY requirements.txt /tmp
COPY secrets/vault-env /bin
RUN yarn install
RUN pip3 install -r /tmp/requirements.txt
RUN serverless config credentials --provider aws --key $AWS_ACCESS_KEY_ID --secret $AWS_ACCESS_KEY_SECRET