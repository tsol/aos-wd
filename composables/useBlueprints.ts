
type Repo = {
  name: string;
  title: string;
  path: string;
  files: string[];
  fetched?: boolean;
  error?: string;
}

const REPOS = [
  { name: 'aos', path: 'permaweb/aos', title: 'AOS permaweb', files: [] },
  { name: 'wd', path: 'tsol/aos-wd', title: 'Widget Desktop', files: [] },
] as Array<Repo>;

export const useBlueprints = () => {

  const repos = ref<typeof REPOS>(REPOS);

  function list(repoName = 'aos') {

    const repo = repos.value.find(r => r.name === repoName);
    if (!repo) throw new Error(`Repo not found ${repoName}`);

    if (repo.fetched) return repo.files;

    const url = `https://api.github.com/repos/${repo.path}/contents/blueprints`;

    fetch(url)
      .then(async (response) => {
        if (response.status === 200) {
          const data = (await response.json()) as { name: string }[];
          const files = data.map(file => file.name);
          repo.files = files;
          return;
        }
        repo.error = `Failed to load blueprints list from ${url}`;
        return;
      })
      .catch((error) => {
        repo.error = error.message;
      })
      .finally(() => {
        repo.fetched = true;
      });

      return repo.files

  }

  async function load(luaFileName: string, repoName = 'aos') {

    const repo = repos.value.find(r => r.name === repoName);
    if (!repo) throw new Error('Repo not found');
  
    const data = await fetch(`https://raw.githubusercontent.com/${repo.path}/main/blueprints/${luaFileName}`)
      .then(res => {
        if (res.status === 200) {
          return res.text()
        }
        repo.error = `Failed to load blueprint ${luaFileName} from ${repo.path}`;
      })
    return data
  }

  return {
    repos,
    list,
    load,
  }
}


