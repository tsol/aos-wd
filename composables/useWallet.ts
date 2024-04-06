import { ArweaveWebWallet } from 'arweave-wallet-connector';

const connected = ref(false);

export const useWallet = () => {

  const arConnect = () => {
    console.log('arConnect');
    (window as any).arweaveWallet
      .connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(() => (connected.value = true));
  };

  const arDisconnect = () => {
    (window as any).arweaveWallet.disconnect().then(() => (connected.value = false));
  }
  
  // const arweaveApp = () => {
//   const wallet = new ArweaveWebWallet({
//     name: 'AOS-WEB',
//   });
//   wallet.setUrl('arweave.app');
//   wallet.connect().then(() => (connected.value = true));
// };

  return { connected, arConnect, arDisconnect };
}

const checkInitialConnection = async () => {
  if ((window as any).arweaveWallet) {
    try {
      const permissions = await (window as any).arweaveWallet.getPermissions();
      connected.value = permissions.includes('SIGN_TRANSACTION') && permissions.includes('ACCESS_ADDRESS');
    } catch (error) {
      console.error('Error checking initial connection:', error);
    }
  }
};

checkInitialConnection();
