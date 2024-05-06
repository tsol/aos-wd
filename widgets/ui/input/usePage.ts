
export function usePage(process: ReturnType<typeof useProcess<any>>) {
 
  function run(command: string) {
    process.command(command);
  }

  return {
    run
  };
}