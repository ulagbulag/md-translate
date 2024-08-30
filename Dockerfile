# Copyright (c) 2024 Ho Kim (ho.kim@ulagbulag.io). All rights reserved.
# Use of this source code is governed by MIT license that can be
# found in the LICENSE file.

# Configure container image variables
ARG IMAGE_REPO="docker.io/library/debian"
ARG IMAGE_VERSION="latest"

# Be ready for serving
FROM "${IMAGE_REPO}:${IMAGE_VERSION}"

# Add License
ADD ./LICENSE /usr/local/share/licenses/md-translate/LICENSE

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    curl \
    jq \
    # Cleanup
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

# Install the package
ADD ./md-translate.sh /usr/local/bin/md-translate.sh
ADD ./prompt.md /usr/local/share/md-translate/prompt.md
ADD ./template.json /usr/local/share/md-translate/template.json
WORKDIR /usr/local/bin

# Configure entrypoint configuration
ENV PROMPT_PATH="/usr/local/share/md-translate/prompt.md"
ENV TEMPLATE_PATH="/usr/local/share/md-translate/template.json"
ENTRYPOINT [ "/usr/bin/env", "/usr/local/bin/md-translate.sh" ]
