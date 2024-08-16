const {execSync} = require('child_process');
const fs = require('fs');


try {
    const gitCommand = (command) => {
        try {
            const f = execSync(`git ${command}`, {encoding: 'utf8'}).trim();
            return f;
        } catch (error) {
            console.error(`Git command "${command}" failed with error:`);
            console.error(error);
            return null
        }
    };

    // Get the current branch name
    const branch = execSync('git rev-parse --abbrev-ref HEAD', {encoding: 'utf8'}).trim();
    // Get the latest version tag for the current branch
    // also remove 'v', to follow pubspec rules
    const version = execSync(`git describe --tags --abbrev=0`, {encoding: 'utf8'}).trim().replace('v', '');
    console.log(`Current branch: ${branch} with tag ${version}\n`)

    if (version) {
        // Read the YAML file
        const filePath = 'pubspec.yaml';
        const fileContents = fs.readFileSync(filePath, 'utf8');
        // Replace the version line or add a new one
        // we don't use a yml parser because it removes spaces and comments which we want to preserve
        const updatedContents = fileContents.replace(
            /^version:.*$/m, `version: ${version}`) || `${fileContents.trim()}\nversion: ${version}`;

        // Write the updated YAML data back to the file
        fs.writeFileSync(filePath, updatedContents);

        console.log(`Version ${version} added to ${filePath}`);

        const accessToken = process.env.GITHUB_TOKEN
        console.log(`access token ${accessToken ? 'found' : 'not found'}`);

        const remoteUrl = gitCommand('config --get remote.origin.url');
        console.log(`Remote URL: ${remoteUrl}`);

        // Push the changes to the remote repository
        gitCommand('config user.name "Pubspec-bot"');
        gitCommand('config user.email "pubspec@bot.com"');
        // Add the pubspec.yaml file to the Git staging area
        gitCommand('add pubspec.yaml');
        // Commit the changes with a message
        gitCommand('commit -m "chore: Update pubspec.yaml version"');

        const url = remoteUrl.substring(remoteUrl.indexOf(':') + 3)
        console.log(url)
        gitCommand(`push https://${accessToken}@${url}`);

        console.log('Successfully pushed the changes to the remote repository.');
    } else {
        console.log(`No version tag found for the current branch (${branch})`);
    }
} catch (e) {
    console.log(`Command failed`);
    console.log(e)
}
