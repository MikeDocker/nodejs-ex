#image=node:6-onbuild
image=mpd-node
project=mpd
tag=latest
registry=registry.preview.openshift.com
remoteImageName=node-6.5.0
source=./views
destination=node4-3-qprq3:/opt/app-root/src
# We use the no-perms option to avoid an error message.
options=--no-perms=true --progress=true

node:
	oc new-app $(image)

# The following block of commands are in the order listed in https://blog.openshift.com/getting-started-docker-registry/

# Login to OpenShift using my own authentication token.
oc-login:
	oc login https://api.preview.openshift.com --token=j_CdOr9tnLk5GyFx2jiePFGxAnev--_vwvr4rXbtTYA

# Authenticate with docker to enable it to access the OpenShift registry
docker-login:
	docker login -u `oc whoami` -p `oc whoami -t` $(registry)

# Tag my node image appropriately.
docker-tag:
	docker tag $(image):$(tag) $(registry)/$(project)/$(remoteImageName)

# Push the image to the openshift docker reghistry.
docker-push:
	docker push $(registry)/$(project)/$(remoteImageName)

# Create a new application from the image we pushed to the openshift docker registry.
oc-new:
	oc new-app $(project) --name=$(remoteImageName)

oc-sync:
	oc rsync $(source) $(destination) $(options)

 .PHONY: docker-login docker-push docker-tag node oc-login oc-new oc-sync
