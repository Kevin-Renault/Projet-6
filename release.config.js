module.exports = {
    // Target the branches that should trigger automated releases
    branches: ['main', 'dev'],
    plugins: [
        '@semantic-release/commit-analyzer',
        '@semantic-release/release-notes-generator',
        '@semantic-release/changelog',
        '@semantic-release/github',
        '@semantic-release/git',
        // Export the computed version to the GitHub Actions environment
        ['@semantic-release/exec', {
            // When GitHub Actions exposes GITHUB_ENV we append the semantic version
            // so subsequent steps automatically see RELEASE_VERSION.
            prepareCmd: 'if [ -n "$GITHUB_ENV" ]; then echo "RELEASE_VERSION=${nextRelease.version}" >> "$GITHUB_ENV"; fi'
        }]
    ],
    changelogFile: 'CHANGELOG.md',
};