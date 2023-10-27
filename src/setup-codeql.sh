#!/bin/bash

# Usage: ./setup-codeql.sh <language> <repository> <issue_number>

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Usage: ./setup-codeql.sh <language> <repository> <issue_number>"
    exit 1
fi

language=$1
repository=$2
issue_number=$3

case $language in
    typescript)
        echo "Setting up codeql for typescript"
        needle="package.json"
        ;;
    csharp)
        echo "Setting up codeql for csharp"
        needle="*.sln"
        ;;
    *)
        echo "Language $language not supported"
        exit 1
        ;;
esac

function update_run_time {
    future_date=$(date -d "+5 minutes" '+%M %H %u')
    read -r minute hour day_of_the_week <<< "$future_date"

    echo "Updating run time"
    sed -i "s|<<MINUTE>>|$minute|" .github/workflows/codeql-analysis.yaml
    sed -i "s|<<HOUR>>|$hour|" .github/workflows/codeql-analysis.yaml
    sed -i "s|<<DAY_OF_THE_WEEK>>|$day_of_the_week|" .github/workflows/codeql-analysis.yaml
}

pushd fork
    # Look for nearest $needle file

    depth=0
    while [[ -z $found ]]; do
        found=$(find . -maxdepth $depth -name "${needle}" -print -quit)
        ((depth++))
    done

    if ! [[ $found ]]; then
        echo "No ${needle} file found, cannot set-up codeql"
        exit 1
    fi

    echo "Nearest $needle file: $found"

    found=$(echo $found | sed "s|${needle}||g")

    mkdir -p .github/workflows

    case $language in
        typescript)
            cat ../templates/${language}/codeql-analysis.yaml | sed "s|<<LOCATION>>|$found|" > .github/workflows/codeql-analysis.yaml
            ;;

        csharp)
            cat ../templates/${language}/codeql-analysis.yaml | sed "s|<<SOLUTIONS_FILE>>|$found|" > .github/workflows/codeql-analysis.yaml
            ;;

        *)
            echo "Language $language not supported"
            exit 1
            ;;

    esac

    update_run_time

    git config user.email "bot@github.com"
    git config user.name "Automated commit"

    git add .github
    git commit -m "Enable codeQL"
    git push -u origin main

    gh issue comment $issue_number --repo $repository -b "Added CodeQL"
popd
