# Plain Lua 5.1 - the version Lightroom Classic runs - for the plug-in's
# logic tests. Test-only: nothing here ships in the plug-in. Pinned: the base
# image by digest and the package by version (Ubuntu 24.04's lua5.1).
FROM ubuntu@sha256:534baea6a22c03a63003dbc8dbe78fe34bc0d7e595d9a9dc9834884ff530eb55
RUN apt-get update \
 && apt-get install -y --no-install-recommends lua5.1=5.1.5-9build2 \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /plugin
