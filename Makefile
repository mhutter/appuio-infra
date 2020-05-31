dry-run = client
MANIFESTS = cockroachdb/cockroachdb-statefulset.yaml

help:
	@echo 'Usage:'
	@echo ''
	@echo '  upstream'
	@echo '    Download all upstream manifests. Note that already downloaded'
	@echo '    manifests will not be downloaded again. To enforce updating them,'
	@echo '    delete them before running "make" (or run "make clean").'
	@echo ''
	@echo '  deploy'
	@echo '    Throw all manifests against the cluster. Make sure you are'
	@echo '    connected to the correct Kubernetes cluster!'
	@echo '    As a safety-measure, "deploy" runs in dry-run mode by default. Set'
	@echo '    "dry-run=none" to actually apply the manifests.'
	@echo ''
	@echo '  clean'
	@echo '    Remove all downloaded manifests (to enforce updating them)'

upstream: $(MANIFESTS)

cockroachdb/cockroachdb-statefulset.yaml:
	curl -sSL -o "$@" "https://github.com/cockroachdb/cockroach/raw/master/cloud/kubernetes/bring-your-own-certs/cockroachdb-statefulset.yaml"

.PHONY: deploy
deploy: cockroachdb/cockroachdb-statefulset.yaml
	ls -1 */kustomization.yml | \
	xargs dirname | \
	while read -r dir; \
		do kubectl apply --dry-run="$(dry-run)" -k "$$dir"; \
	done

clean:
	rm -f $(MANIFESTS)
