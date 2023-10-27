#!/bin/bash

set -euo pipefail

echo "| Check | Result |" > result.md
echo "|---|---|" >> result.md
echo "| Last updated | $UPDATED_AT |" >> result.md

if [ $HAS_GITHUB_FOLDER == false  ]; then
    echo "| No .github folder found | ⛔️ |" >> result.md
fi

if [ $HAS_WORKFLOWS_FOLDER == false ]; then
    echo "| No Workflows found | ⛔️ |" >> result.md
fi

if [ $HAS_DEPENDABOT_CONFIGURATION == true ]; then
    echo "| Dependabot configuration found | ✅ |" >> result.md
else
    echo "| No Dependabot configuration found | ⛔️ |" >> result.md
fi

if [ $HAS_CODEQL_INIT == true ]; then
    echo "| CodeQL Init found in $WORKFLOW_WITH_CODEQL_INIT | ✅ |" >> result.md
else
    echo "| No CodeQL Init found | ⛔️ |" >> result.md
fi

if [ $HAS_CODEQL_ANALYZE == true ]; then
    echo "| CodeQL Analyze found in $WORKFLOW_WITH_CODEQL_ANALYZE | ✅ |" >> result.md
else
    echo "| No CodeQL Analyze found | ⛔️ |" >> result.md
fi

cat result.md
