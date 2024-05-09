import fs from 'fs'
import path from 'path'
import replace from 'lodash.replace';

function writeBundle() {
  const distDir = path.resolve('dist')
  const indexHtmlPath = path.join(distDir, 'index.html')
  let indexHtml = fs.readFileSync(indexHtmlPath, 'utf-8')

  fs.readdirSync(distDir).forEach(file => {

    if (file.endsWith('.css')) {
      const cssFilePath = path.join(distDir, file)
      const cssFileContent = fs.readFileSync(cssFilePath, 'utf-8')
      indexHtml = indexHtml.replace(
        new RegExp(`<link rel="stylesheet".+?href="/${file}">`),
        `<style>${cssFileContent}</style>`
      )
      fs.unlinkSync(cssFilePath)
    }

    if (file.endsWith('.js')) {
      const jsFilePath = path.join(distDir, file)
      const jsFileContent = fs.readFileSync(jsFilePath, 'utf-8')

      console.log('file:', file, 'filePath:', jsFilePath);
      
      indexHtml = replace(indexHtml,
        new RegExp(`<script type="module".+?src="/${file}"></script>`),
        ''
      )

      const parts = indexHtml.split('<!--js-->');
      indexHtml = parts[0] + '<script type="module">' + jsFileContent + '</script>\n\n' + parts[1];

      fs.unlinkSync(jsFilePath)
    }

  })

  fs.writeFileSync(indexHtmlPath, indexHtml)
}

writeBundle();

