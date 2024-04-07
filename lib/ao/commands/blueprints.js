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