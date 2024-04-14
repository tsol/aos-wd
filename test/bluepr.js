import { listBlueprints } from '../lib/ao/commands/blueprints.js';


async function main() {
    console.log(await listBlueprints());
}

main();