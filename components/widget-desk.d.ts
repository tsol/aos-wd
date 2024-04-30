declare global {
  interface Window {
    open(url: string, target?: string): void;
  }
}