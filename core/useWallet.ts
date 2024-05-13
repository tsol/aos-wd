import { ref, computed } from 'vue';

const ourPID = ref<string>('');

export const useWallet = (onConnect?: () => void) => {

  function getAWW() {
    const aww = (window as any).arweaveWallet;
    if (!aww) {
      alert('Install arweave');
      throw new Error('arweaveWallet not found');
    }
    return aww;
  }

  const arConnect = () => {
    getAWW()
      .connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS'])
      .then(async () => {
        ourPID.value = await getAWW().getActiveAddress();
        if (onConnect) onConnect();
      });
  };

  const arDisconnect = () => {
    getAWW().disconnect().then(() => (ourPID.value = ''));
  }


  async function init() {

    if (!getAWW()) return false;

    try {
      const permissions = await getAWW().getPermissions();
      const connected = permissions.includes('SIGN_TRANSACTION') && permissions.includes('ACCESS_ADDRESS');
      if (!connected) return false;
      ourPID.value = await getAWW().getActiveAddress();
      if (onConnect) onConnect();
      return true;

    } catch (error) {
      console.error('Error checking initial connection:', error);
    }

  }

  const connected = computed(() => !!ourPID.value);

  init();

  return { connected, ourPID, arConnect, arDisconnect, getAWW };
}
