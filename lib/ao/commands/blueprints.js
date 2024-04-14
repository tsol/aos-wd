export async function loadBlueprint(name) {
  const data = await fetch(`https://raw.githubusercontent.com/permaweb/aos/main/blueprints/${name}.lua`)
    .then(res => {
      if (res.status === 200) {
        return res.text()
      }
      throw new Error("blueprint not found")
    })
  return data
}

export async function listBlueprints() {
  const url = 'https://api.github.com/repos/permaweb/aos/contents/blueprints';
  //const url = 'https://api.github.com/repos/permaweb/aos/contents';
  
  const response = await fetch(url);
  if (response.status === 200) {
    const data = await response.json();
    return data.map(file => file.name);
  }
  throw new Error('Failed to load blueprints');
}