hooks:
	@mkdir -p .git/hooks 
	@printf '#!/bin/sh\n./hooks/pre-commit-helm-dependency.sh' > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit

.PHONY: hooks
