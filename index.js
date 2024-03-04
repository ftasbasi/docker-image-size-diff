const { execSync } = require('child_process');

// Function to install necessary packages
const installPackages = () => {
    try {
        execSync('apk add --no-cache bash jq yq docker-cli');
    } catch (error) {
        console.error('Error installing packages:', error.message);
        process.exit(1);
    }
};

// Function to compare Docker image layer sizes
const compareImageLayers = (repoList, oldRelease, newRelease) => {
    const repos = repoList.split(' ');

    for (const repo of repos) {
        try {
            // Obtain image layers data from Docker Hub and store locally
            execSync(`docker manifest inspect ${repo}:${oldRelease} | yq -r '.' | jq '.layers' > old_layers.txt`);
            execSync(`docker manifest inspect ${repo}:${newRelease} | yq -r '.' | jq '.layers' > new_layers.txt`);

            // Rest of your comparison logic goes here

        } catch (error) {
            console.error(`Error comparing image layers for ${repo}:`, error.message);
        }
    }
};

// Entry point function
const run = () => {
    const repoList = process.env.REPO_LIST;
    const oldRelease = process.env.OLD_RELEASE;
    const newRelease = process.env.NEW_RELEASE;

    // Check if the REPO_LIST value is provided
    if (!repoList) {
        console.error('Error: REPO_LIST input is required.');
        process.exit(1);
    }

    // Install necessary packages
    installPackages();

    // Compare Docker image layer sizes
    compareImageLayers(repoList, oldRelease, newRelease);
};

// Run the action
run();
