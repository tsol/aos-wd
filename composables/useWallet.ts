// import { ArweaveWebWallet } from 'arweave-wallet-connector';

import { usePersistStore } from "~/store/persist";

const connected = ref(false);

export const useWallet = () => {

  const arConnect = () => {
    console.log('arConnect');
    (window as any).arweaveWallet
      .connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(() => {
        updateListOfProcesses();  
        connected.value = true;
      });
  };

  const arDisconnect = () => {
    (window as any).arweaveWallet.disconnect().then(() => (connected.value = false));
  }
  
  return { connected, arConnect, arDisconnect };
}

async function updateListOfProcesses() {

    const persistStore = usePersistStore();
    const processes = await useProcesses().queryAllProcessesWithNames();
  
    if (processes.length > 0) {
      processes.forEach((p) => {
        persistStore.addProcess(p, false);
      });
    }
}

const checkInitialConnection = async () => {
  if ((window as any).arweaveWallet) {
    try {
      const permissions = await (window as any).arweaveWallet.getPermissions();
      connected.value = permissions.includes('SIGN_TRANSACTION') && permissions.includes('ACCESS_ADDRESS');
      if (connected.value) {
        updateListOfProcesses();
      }
    } catch (error) {
      console.error('Error checking initial connection:', error);
    }
  }
};

checkInitialConnection();
