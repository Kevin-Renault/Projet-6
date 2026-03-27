const {
    angularPackageJsonAsset,
    javaBuildGradleAsset
} = require('./paths.config');

module.exports = {
    // main publishes stable releases, dev publishes prereleases.
    branches: [
        'main',
        { name: 'dev', channel: 'dev', prerelease: 'dev' }
    ],
    plugins: [
        '@semantic-release/commit-analyzer',
        '@semantic-release/release-notes-generator',
        '@semantic-release/changelog',
        // Synchronize the npm/Gradle versions before the git plugin runs
        ['@semantic-release/exec', {
            prepareCmd: 'node scripts/sync-version.js ${nextRelease.version}'
        }],
        '@semantic-release/github',
        ['@semantic-release/git', {
            assets: [
                angularPackageJsonAsset,
                javaBuildGradleAsset
                , 'CHANGELOG.md'
            ],
            message: 'chore(release): ${nextRelease.version} [skip ci]'
        }]
    ],
    changelogFile: 'CHANGELOG.md',
};