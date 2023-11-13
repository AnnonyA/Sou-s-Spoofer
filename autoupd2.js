const { Octokit } = require('@octokit/core');
const fs = require('fs');
const path = require('path');

const octokit = new Octokit();

const owner = 'AnnonyA'; // here's mi acc vortex acc = 091236515123075625531
const repo = 'Voraton-V5-Cracked'; // here's mi repo vortex repo = 9142015212
async function downloadRepoFiles() {
  try {
    const response = await octokit.request('GET /repos/{owner}/{repo}/contents', {
      owner,
      repo,
    });

    for (const item of response.data) {
      if (item.type === 'file') {
        const fileContent = await octokit.request('GET /repos/{owner}/{repo}/contents/{path}', {
          owner,
          repo,
          path: item.path,
        });

        const filePath = path.join(__dirname, item.path);
        fs.writeFileSync(filePath, Buffer.from(fileContent.data.content, 'base64'));

        console.log(`Downloaded: ${item.path}`);
      }
    }

    console.log('All files downloaded successfully.');
  } catch (error) {
    console.error('Error downloading repository:', error);
  }
}

downloadRepoFiles();