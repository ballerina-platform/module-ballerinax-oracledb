# Copyright (c) 2021, WSO2 Inc. (http://wso2.com) All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Dockerfile using dockerhub repository image
ARG REPO_LOCATION=niveathika/oracle-enterprise
ARG BASE_VERSION=12.2.0.1-slim
FROM ${REPO_LOCATION}:${BASE_VERSION}

# copy wallet files and configDBora.sh file
COPY wallets/server-wallet/ /home/usr/wallet/
RUN rm -rf /home/oracle/setup/configDBora.sh
COPY setup/configDBora.sh /home/oracle/setup

# Setup database using sqlplus script
COPY sql-scripts/ /home/oracle/sql-scripts/
EXPOSE 2484
