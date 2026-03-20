module.exports = {
    // Target the branches that should trigger automated releases
    branches: ['main', 'dev'],
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
                'package.json',
                'G-rez-l-int-gration-et-la-livraison-continue-Application-Java/build.gradle'
            ],
            message: 'chore(release): ${nextRelease.version} [skip ci]'
        }]
    ],
    changelogFile: 'CHANGELOG.md',
};