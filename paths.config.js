const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname);
const DOTENV_PATH = path.join(ROOT, '.env');

function loadEnv() {
    if (!fs.existsSync(DOTENV_PATH)) {
        return {};
    }
    return fs.readFileSync(DOTENV_PATH, 'utf-8')
        .split(/\r?\n/)
        .map(line => line.trim())
        .filter(line => line && !line.startsWith('#'))
        .reduce((acc, line) => {
            const [key, ...rest] = line.split('=');
            acc[key] = rest.join('=');
            return acc;
        }, {});
}

const env = loadEnv();
const ANGULAR_APP_DIR = env.ANGULAR_DIR || 'G-rez-l-int-gration-et-la-livraison-continue-Application-Angular';
const JAVA_APP_DIR = env.JAVA_DIR || 'G-rez-l-int-gration-et-la-livraison-continue-Application-Java';

module.exports = {
    ROOT,
    ANGULAR_APP_DIR,
    JAVA_APP_DIR,
    angularPackageJsonPath: path.join(ROOT, ANGULAR_APP_DIR, 'package.json'),
    javaBuildGradlePath: path.join(ROOT, JAVA_APP_DIR, 'build.gradle'),
    angularPackageJsonAsset: `${ANGULAR_APP_DIR}/package.json`,
    javaBuildGradleAsset: `${JAVA_APP_DIR}/build.gradle`,
};
