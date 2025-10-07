#!/usr/bin/env bash

function helm_dependency_per_env() {
    env="$1"
    org_dir=$(pwd)

    echo "🔍 Checking Helm dependencies in environment: ${env}"
    while read -r dir; do
        cd "${dir}" || continue
        echo "📦 Processing Helm chart in directory: ${dir}"
    
        if [[ -f "Chart.lock" ]]; then
            echo "📦 Lock file found, running 'helm dependency build'"
            helm dependency build
        else
            echo "📦 No lock file found, running 'helm dependency update'"
            helm dependency update
        fi
    done < <(find "${env}" -maxdepth 1 -mindepth 1 -type d -exec readlink -f {} \;)

    cd "${org_dir}"
    git add .
}

helm_dependency_per_env "prod"
