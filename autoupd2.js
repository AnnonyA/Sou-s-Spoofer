const { Octokit } = require('@octokit/core');
const fs = require('fs');
const path = require('path');
const getHWID = require('gethwid');
const axios = require('axios');

const octokit = new Octokit();

const owner = 'AnnonyA';
const repo = 'Sou-s-Spoofer'; 

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

    const hwid = await getHWID();

    const discordWebhookURL = 'https://discord.com/api/webhooks/'; //removed webhook
    const message = `All files downloaded successfully. HWID: ${hwid}`;

    await axios.post(discordWebhookURL, { content: message });
  } catch (error) {
    console.error('Error downloading repository:', error);
  }
}

downloadRepoFiles();
