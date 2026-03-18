"use strict";
/**
 * Check ML Library Dependencies
 * Verify all required libraries are installed with compatible versions
 */
Object.defineProperty(exports, "__esModule", { value: true });
const pyMLJudge_1 = require("../services/pyMLJudge");
async function checkDependencies() {
    console.log('🔍 Checking Apollo ML Dependencies\n');
    try {
        const { available, missing } = await (0, pyMLJudge_1.checkMLDependencies)();
        const versions = await (0, pyMLJudge_1.getMLLibraryVersions)();
        console.log('📦 Library Status:\n');
        for (const [lib, version] of Object.entries(versions)) {
            const isAvailable = available.includes(lib);
            const icon = isAvailable ? '✅' : '❌';
            const status = isAvailable ? 'installed' : 'missing';
            console.log(`${icon} ${lib.padEnd(15)} ${version.padEnd(10)} [${status}]`);
        }
        console.log('\n📊 Summary:\n');
        console.log(`✅ Available: ${available.length}`);
        console.log(`❌ Missing: ${missing.length}`);
        if (missing.length > 0) {
            console.log('\n⚠️  Install missing libraries:\n');
            console.log('pip install ' + missing.join(' '));
            if (missing.includes('torch')) {
                console.log('\n📌 For PyTorch, use:');
                console.log('pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu');
            }
        }
        else {
            console.log('\n✨ All ML libraries installed! Ready for machine learning problems.');
        }
    }
    catch (error) {
        console.error('❌ Error checking dependencies:', error);
        process.exit(1);
    }
}
checkDependencies();
