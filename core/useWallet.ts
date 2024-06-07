import { ref, computed } from 'vue';

const ourPID = ref<string>('');
const errorMsg = ref<string>('');

export const useWallet = (onConnect?: () => void) => {


  function checkSignMethod() {
    if (! window.arweaveWallet.signDataItem) {
      console.error('arweaveWallet.signDataItem not found');
      errorMsg.value = 'signDataItem is missing in arewaveWallet implementation';
    }
  }

  function getAWW() {
    const aww = (window as any).arweaveWallet;
    if (!aww) {
      console.error('arweaveWallet not found');
      errorMsg.value = 'ARweave wallet extension not found';
      return undefined;
    }
    return aww;
  }

  const arConnect = () => {
    console.log('useWallet-arConnect');
    getAWW()?.connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(async () => {
        ourPID.value = await getAWW().getActiveAddress();
        if (onConnect) onConnect();
        errorMsg.value = '';
        checkSignMethod();
      });
  };

  const arDisconnect = () => {
    console.log('useWallet-arDisconnect');
    getAWW()?.disconnect().then(() => (ourPID.value = ''));
  }

  async function init() {

    console.log('useWallet-init');
    if (!getAWW()) return false;

    try {
      const permissions = await getAWW().getPermissions();
      const connected = 
        permissions.includes('SIGN_TRANSACTION') &&
        permissions.includes('ACCESS_ADDRESS');

      if (!connected) return arConnect();
      ourPID.value = await getAWW().getActiveAddress();
      if (onConnect) onConnect();
      errorMsg.value = '';
      checkSignMethod();

      return true;

    } catch (error) {
      errorMsg.value = 'Error checking initial connection';
      console.error('Error checking initial connection:', error);
    }

  }

  const connected = computed(() => !!ourPID.value && !errorMsg.value);

  return { connected, ourPID, errorMsg, init, arConnect, arDisconnect, getAWW };
}
