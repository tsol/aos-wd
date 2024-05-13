// import { ArweaveWebWallet } from 'arweave-wallet-connector';

import { usePersistStore } from "~/store/persist";

const ourPID = ref<string>('');

export const useWallet = () => {

  const arConnect = () => {
    getAWW()
      .connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(async () => {
        updateListOfProcesses();
        ourPID.value = await getAWW().getActiveAddress();
      });
  };

  const arDisconnect = () => {
    getAWW().disconnect().then(() => (ourPID.value = ''));
  }
  
  const connected = computed(() => !!ourPID.value);

  return { connected, ourPID, arConnect, arDisconnect };
}

function getAWW() {
  const aww =  (window as any).arweaveWallet;
  if (!aww) {
    alert('Install arweave');
    throw new Error('arweaveWallet not found');
  }
  return aww;
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
  if (getAWW()) {
    try {
      const permissions = await (window as any).arweaveWallet.getPermissions();
      const connected = permissions.includes('SIGN_TRANSACTION') && permissions.includes('ACCESS_ADDRESS');
      if (connected) {
        updateListOfProcesses();
        ourPID.value = await getAWW().getActiveAddress();
        console.log('Our Wallet PID:', ourPID.value);
      }
    } catch (error) {
      console.error('Error checking initial connection:', error);
    }
  }
};

checkInitialConnection();
