#!/bin/bash

set -euo pipefail

function github_folder_checks() {
    updated_at=$(git log -1 --format="%at" | xargs -I{} date -d @{} +%Y/%m/%dT%H:%M:%S)
    echo "updated_at=${updated_at}" >> $GITHUB_OUTPUT

    echo "Checking for files in the .github folder"
    if [ ! -d "action/.github" ] ; then
        echo "has_github_folder=false" >> $GITHUB_OUTPUT
        echo "has_workflows_folder=false" >> $GITHUB_OUTPUT
        echo "has_dependabot_configuration=false" >> $GITHUB_OUTPUT
        echo "has_codeql_init=false" >> $GITHUB_OUTPUT
        echo "has_codeql_analyze=false" >> $GITHUB_OUTPUT

        exit 0
    fi

    echo "has_github_folder=true" >> $GITHUB_OUTPUT

    if [[ -n $(find action/.github -maxdepth 1 -name dependabot.yml) ]] ; then
        echo "has_dependabot_configuration=true" >> $GITHUB_OUTPUT
    else
        echo "has_dependabot_configuration=false" >> $GITHUB_OUTPUT
    fi

    if [ ! -d "action/.github/workflows" ]; then
        echo "has_workflows_folder=false" >> $GITHUB_OUTPUT
        echo "has_codeql_init=false" >> $GITHUB_OUTPUT
        echo "has_codeql_analyze=false" >> $GITHUB_OUTPUT

        exit 0
    fi

    echo "has_workflows_folder=true" >> $GITHUB_OUTPUT

    # Look for CodeQL init workflow
    if [ `grep action/.github/workflows/*.yml -e 'uses: github/codeql-action/init' | wc -l` -gt 0 ]; then
        WORKFLOW_INIT=`grep action/.github/workflows/*.yml -e 'uses: github/codeql-action/init' -H | cut -f1 -d' ' | sed "s/:$//g"`
        echo "workflow_with_codeql_init=${WORKFLOW_INIT}" >> $GITHUB_OUTPUT
        echo "has_codeql_init=true" >> $GITHUB_OUTPUT
    else
        echo "has_codeql_init=false" >> $GITHUB_OUTPUT
    fi

    # Look for CodeQL analyze workflow
    if [ `grep action/.github/workflows/*.yml -e 'uses: github/codeql-action/analyze' | wc -l` -gt 0 ]; then
        WORKFLOW_ANALYZE=`grep action/.github/workflows/*.yml -e 'uses: github/codeql-action/analyze' -H | cut -f1 -d' ' | sed "s/:$//g"`
        echo "workflow_with_codeql_analyze=${WORKFLOW_ANALYZE}" >> $GITHUB_OUTPUT
        echo "has_codeql_analyze=true" >> $GITHUB_OUTPUT
    else
        echo "has_codeql_analyze=false" >> $GITHUB_OUTPUT
    fi
}

github_folder_checks
