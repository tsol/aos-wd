import { ref } from 'vue';

const ourPID = ref<string>('');

export function useAWW() {

  function getAWW() {
    const aww =  (window as any).arweaveWallet;
    if (!aww) {
      alert('Install arweave');
      throw new Error('arweaveWallet not found');
    }
    return aww;
  }
  
  function arConnect() {
    console.log('arConnect');
  
    const aww = getAWW();
  
    if (!aww) {
      console.error('arConnect: arweaveWallet not found');
      return;
    }
  
    aww
      .connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(() => {
        console.log('wallet connected');
        arFetchAddress();
      });
  };
  
  function arDisconnect() {
    getAWW().disconnect().then(() => console.log('wallet disconnected'));
  }
  
  async function arFetchAddress() {
    const a =  await getAWW().getActiveAddress();
    ourPID.value = a;
  }

  arConnect();

  return {
    arConnect,
    arDisconnect,
    arFetchAddress,
    ourPID
  }
}

