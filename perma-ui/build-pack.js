import fs from 'fs'
import path from 'path'
import zlib from 'zlib';

function gzipAndBase64(input) {
  const buffer = Buffer.from(input, 'utf-8');
  const gzipped = zlib.gzipSync(buffer);
  const base64 = gzipped.toString('base64');
  return base64;
}

function writeBundle() {
  const distDir = path.resolve('dist')
  const indexHtmlPath = path.join(distDir, 'index.html')
  const indexTplPath = './index.html';

  let indexHtml = fs.readFileSync(indexTplPath, 'utf-8')

  fs.readdirSync(distDir).forEach(file => {

    if (file.endsWith('.css')) {
      const cssFilePath = path.join(distDir, file)
      const cssFileContent = fs.readFileSync(cssFilePath, 'utf-8')
      indexHtml = indexHtml.replace(
        new RegExp('<!--css-->'),
        gzipAndBase64(cssFileContent)
      )
      fs.unlinkSync(cssFilePath)
    }

    if (file.endsWith('.js')) {
      const jsFilePath = path.join(distDir, file)
      const jsFileContent = fs.readFileSync(jsFilePath, 'utf-8')

      const parts = indexHtml.split('<!--js-->');
      indexHtml = parts[0] + 
      gzipAndBase64(jsFileContent)
      + parts[1];

      fs.unlinkSync(jsFilePath)
    }

  })

  fs.writeFileSync(indexHtmlPath, indexHtml)
}

writeBundle();

