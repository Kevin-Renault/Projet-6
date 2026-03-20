const fs = require('fs');
const {
    angularPackageJsonPath,
    javaBuildGradlePath
} = require('../paths.config');

const version = process.argv[2];
if (!version) {
    console.error('Usage: node sync-version.js <version>');
    process.exit(1);
}

function updatePackageJson() {
    const pkgPath = angularPackageJsonPath;
    const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
    pkg.version = version;
    fs.writeFileSync(pkgPath, `${JSON.stringify(pkg, null, 2)}\n`);
    console.log(`Updated package.json to ${version}`);
}

function updateBuildGradle() {
    const gradlePath = javaBuildGradlePath;
    let content = fs.readFileSync(gradlePath, 'utf-8');
    const versionLine = /version\s*=\s*['"][^'"]+['"]/;
    if (!versionLine.test(content)) {
        throw new Error('Cannot find version line in build.gradle');
    }
    content = content.replace(versionLine, `version = '${version}'`);
    fs.writeFileSync(gradlePath, content);
    console.log(`Updated build.gradle to ${version}`);
}

function exposeReleaseVersion() {
    const githubEnv = process.env.GITHUB_ENV;
    if (githubEnv) {
        fs.appendFileSync(githubEnv, `RELEASE_VERSION=${version}\n`);
        console.log(`Appended RELEASE_VERSION=${version} to GITHUB_ENV`);
    }
}

updatePackageJson();
updateBuildGradle();
exposeReleaseVersion();
